from typing import Dict, Any, List
from app.services.trust_config import (
    WEIGHT_DIRECT,
    WEIGHT_HISTORY,
    WEIGHT_COMMUNICATION,
    WEIGHT_XAI,
    TRUST_MIN,
    TRUST_MAX,
    INITIAL_TRUST
)
from app.services.trust_rules import TrustRulesEngine, TRUST_RECOVERY_RATE

class TrustCalculator:
    """
    Computes dynamic trust scores combining current classifications,
    historical trends, messaging frequency, and explainable AI metrics.
    """
    def calculate_direct_trust(
        self, 
        prediction: int, 
        speed_score: float, 
        position_score: float
    ) -> float:
        """
        Calculates direct trust (40% weight target) based on model prediction
        and feature consistency checks.
        """
        prediction_score = 0.0 if prediction == 1 else 100.0
        # Average prediction flag and behavioral checks
        return (prediction_score * 0.5) + (speed_score * 0.25) + (position_score * 0.25)

    def calculate_historical_trust(
        self, 
        previous_trust: float, 
        normal_duration: int, 
        attack_history: List[str]
    ) -> float:
        """
        Calculates historical trust (30% weight target) applying normal behavior
        recovery bonuses or penalty decrements.
        """
        if previous_trust is None:
            return INITIAL_TRUST

        # If last event was Normal, apply gradual recovery increment
        last_attack = attack_history[-1] if attack_history else "NONE"
        if last_attack == "NONE":
            recovered = previous_trust + TRUST_RECOVERY_RATE
            return min(recovered, TRUST_MAX)

        # If last event was Malicious, apply rules engine penalty deduction
        # Find count of this specific attack in history to scale multiplier
        repeated_count = attack_history.count(last_attack)
        severity = TrustRulesEngine.get_severity(last_attack)
        penalty = TrustRulesEngine.calculate_penalty(severity, repeated_count)

        deducted = previous_trust - penalty
        return max(deducted, TRUST_MIN)

    def calculate_communication_trust(self, comm_score: float) -> float:
        """Calculates communication trust (20% weight target)."""
        return comm_score

    def calculate_xai_severity_score(
        self, 
        prediction: int, 
        lime_values: Dict[str, float]
    ) -> float:
        """
        Calculates explanation-driven confidence severity scores (10% weight target).
        Larger LIME weights indicate severe anomalies.
        """
        if prediction == 0 or not lime_values:
            return 100.0

        # Extract maximum contributing weight increasing malicious probability
        max_contrib = max([val for val in lime_values.values() if val > 0], default=0.0)
        
        # Scale LIME coefficient (range usually 0.0 to 1.0)
        penalty = min(max_contrib * 100.0, 100.0)
        return max(100.0 - penalty, 0.0)

    def compute_composite_trust(
        self, 
        direct: float, 
        history: float, 
        comm: float, 
        xai: float
    ) -> float:
        """Applies the composite weighted trust score equation."""
        composite = (
            (direct * WEIGHT_DIRECT) +
            (history * WEIGHT_HISTORY) +
            (comm * WEIGHT_COMMUNICATION) +
            (xai * WEIGHT_XAI)
        )
        return round(float(composite), 2)
