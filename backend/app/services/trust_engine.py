import uuid
from datetime import datetime
from typing import Dict, Any
from app.core.logging import logger
from app.services.history_manager import VehicleHistoryManager
from app.services.behavior_analyzer import BehaviorAnalyzer
from app.services.trust_calculator import TrustCalculator
from app.services.trust_updater import TrustUpdater
from app.services.trust_rules import TrustRulesEngine

class TrustEngine:
    """
    Orchestration class integrating historical state tracking, behavioral checks,
    and mathematical computations into a single trust management framework.
    """
    def __init__(
        self,
        history_manager: VehicleHistoryManager = None,
        analyzer: BehaviorAnalyzer = None,
        calculator: TrustCalculator = None,
        updater: TrustUpdater = None
    ):
        self.history_manager = history_manager or VehicleHistoryManager()
        self.analyzer = analyzer or BehaviorAnalyzer()
        self.calculator = calculator or TrustCalculator()
        self.updater = updater or TrustUpdater()

    def process_telemetry_event(
        self, 
        vehicle_id: str, 
        prediction: int, 
        attack_type: str, 
        xai_lime_values: Dict[str, float],
        message_features: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Executes a single trust updating iteration for a vehicle.
        Saves logs and outputs database schema serialization.
        """
        logger.info(f"Trust Engine processing event for vehicle: {vehicle_id}...")

        # 1. Load history
        history = self.history_manager.load_history(vehicle_id)
        
        # Get previous trust value (default to 100.0 if empty history)
        previous_trust = history["trust_history"][-1] if history["trust_history"] else 100.0

        # 2. Execute direct behavioral checks
        speed_score = self.analyzer.analyze_speed_consistency(message_features)
        position_score = self.analyzer.analyze_position_consistency(message_features)
        comm_score = self.analyzer.analyze_communication_behavior(message_features)

        # 3. Calculate components
        direct_trust = self.calculator.calculate_direct_trust(prediction, speed_score, position_score)
        
        # Build temp list of attack types including current one to let the rules engine evaluate
        temp_attacks = list(history["attack_history"]) + [attack_type]
        historical_trust = self.calculator.calculate_historical_trust(
            previous_trust=previous_trust,
            normal_duration=history["normal_run_duration"],
            attack_history=temp_attacks
        )
        
        communication_trust = self.calculator.calculate_communication_trust(comm_score)
        xai_severity = self.calculator.calculate_xai_severity_score(prediction, xai_lime_values)

        # 4. Resolve composite score
        current_trust = self.calculator.compute_composite_trust(
            direct=direct_trust,
            history=historical_trust,
            comm=communication_trust,
            xai=xai_severity
        )

        # 5. Resolve status category
        trust_status = self.updater.resolve_status(current_trust)

        # 6. Save event log details
        self.history_manager.record_event(
            vehicle_id=vehicle_id,
            prediction=prediction,
            attack_type=attack_type,
            trust_score=current_trust,
            message_features=message_features
        )

        # 7. Generate reason sentence
        attack_detected = (prediction == 1)
        severity = TrustRulesEngine.get_severity(attack_type) if attack_detected else "NONE"
        
        if attack_detected:
            reason = f"Anomalous behavior identified. Penalty applied for {attack_type} ({severity} severity)."
        else:
            reason = "Standard messaging patterns observed. Trust values stable."

        db_record = {
            "id": str(uuid.uuid4()),
            "vehicle_id": vehicle_id,
            "previous_score": previous_trust,
            "current_score": current_trust,
            "trust_status": trust_status,
            "reason": reason,
            "attack_detected": attack_detected,
            "severity": severity,
            "timestamp": datetime.utcnow().isoformat()
        }

        logger.info(f"Trust update completed. Vehicle: {vehicle_id} | Score: {current_trust} | Status: {trust_status}")
        return db_record
