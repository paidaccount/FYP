from typing import Dict, Any

# Attack severity mapping configurations
ATTACK_SEVERITY_LEVELS: Dict[str, str] = {
    "message_frequency_anomaly": "LOW",
    "speed_anomaly": "MEDIUM",
    "position_anomaly": "MEDIUM",
    "DoS": "HIGH",
    "Sybil": "HIGH",
    "fake_emergency": "HIGH"
}

# Penalty scores per severity
SEVERITY_PENALTIES: Dict[str, float] = {
    "NONE": 0.0,
    "LOW": 15.0,
    "MEDIUM": 30.0,
    "HIGH": 50.0,
    "CRITICAL": 80.0
}

# Normal recovery increment per epoch
TRUST_RECOVERY_RATE = 2.0

class TrustRulesEngine:
    """
    Evaluates rule criteria based on ML prediction flags, attack count thresholds,
    and recovery states.
    """
    @staticmethod
    def get_severity(attack_type: str) -> str:
        """Resolves severity rating for a specific attack type."""
        return ATTACK_SEVERITY_LEVELS.get(attack_type, "MEDIUM")

    @staticmethod
    def calculate_penalty(severity: str, repeated_attack_count: int) -> float:
        """
        Calculates penalty value, applying progressive multipliers for repeated attacks.
        """
        base_penalty = SEVERITY_PENALTIES.get(severity, 0.0)
        
        # If repeated attacks, scale penalty multiplier progressively
        if repeated_attack_count > 1:
            multiplier = 1.0 + (repeated_attack_count - 1) * 0.5
            return min(base_penalty * multiplier, 100.0)
            
        return base_penalty
