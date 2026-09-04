from typing import Dict, Any, List
from app.core.logging import logger
from app.services.emergency.vehicle_authentication import VehicleAuthenticator
from app.services.emergency.fake_emergency_detector import FakeEmergencyDetector
from app.services.emergency.priority_manager import PriorityManager
from app.services.emergency.eta_calculator import ETACalculator
from app.services.emergency.schemas import EmergencyVerificationRequest, PriorityCalculationRequest

class EmergencyDetector:
    """
    Orchestration class managing the complete verification pipeline:
    Auth Verify -> Trust Check -> Anomaly Eval -> Priority Calc -> Alert Dispatch.
    """
    def __init__(
        self,
        authenticator: VehicleAuthenticator = None,
        fake_detector: FakeEmergencyDetector = None,
        priority_manager: PriorityManager = None,
        eta_calculator: ETACalculator = None
    ):
        self.authenticator = authenticator or VehicleAuthenticator()
        self.fake_detector = fake_detector or FakeEmergencyDetector()
        self.priority_manager = priority_manager or PriorityManager()
        self.eta_calculator = eta_calculator or ETACalculator()

    def process_emergency_request(
        self,
        auth_request: EmergencyVerificationRequest,
        trust_score: float,
        ml_prediction: int,
        attack_history: List[str],
        comm_anomaly_detected: bool,
        distance_km: float,
        traffic_condition: str,
        road_availability: bool,
        accident_severity: str = "NONE"
    ) -> Dict[str, Any]:
        """
        Processes a vehicle's emergency broadcast claim.
        Returns validation results, priority levels, ETAs, and alerts.
        """
        logger.info(f"Processing emergency claim request for vehicle: {auth_request.vehicle_id}...")

        # 1. Verify Identity
        auth_res = self.authenticator.verify_credentials(auth_request)

        # 2. Check for suspicious claim indicators
        is_fake = self.fake_detector.is_suspicious_claim(
            auth_response=auth_res,
            trust_score=trust_score,
            ml_prediction=ml_prediction,
            attack_history=attack_history,
            comm_anomaly_detected=comm_anomaly_detected
        )

        if is_fake:
            # Reject request and apply penalties
            security_actions = self.fake_detector.handle_fake_claim(auth_request.vehicle_id, trust_score)
            
            return {
                "status": "REJECTED",
                "verification_result": "Fake Emergency Claim",
                "penalized_trust": security_actions["penalized_trust"],
                "alert": security_actions["security_alert"],
                "priority_level": "Low",
                "eta_minutes": 0.0,
                "reason": auth_res.reason if not auth_res.is_valid else "Rejected due to anomalous behavior history or low trust standing."
            }

        # 3. Request accepted - Calculate priority and ETA
        priority_req = PriorityCalculationRequest(
            vehicle_id=auth_request.vehicle_id,
            vehicle_type=auth_request.emergency_type,
            distance=distance_km,
            trust_score=trust_score,
            traffic_condition=traffic_condition,
            road_availability=road_availability,
            accident_severity=accident_severity
        )
        priority_res = self.priority_manager.calculate_priority(priority_req)

        eta = self.eta_calculator.calculate_eta(
            distance_km=distance_km,
            vehicle_type=auth_request.emergency_type,
            traffic_condition=traffic_condition
        )

        alert_msg = f"Emergency vehicle approaching. Please give way."

        return {
            "status": "ACCEPTED",
            "verification_result": "Authenticated Emergency Vehicle",
            "priority_level": priority_res.priority_level,
            "priority_score": priority_res.priority_score,
            "eta_minutes": eta,
            "alert": {
                "message": alert_msg,
                "emergency_type": auth_request.emergency_type,
                "vehicle_id": auth_request.vehicle_id,
                "distance": distance_km,
                "eta_minutes": eta,
                "priority_level": priority_res.priority_level
            },
            "reason": "Vehicle successfully authenticated and validation criteria met."
        }
