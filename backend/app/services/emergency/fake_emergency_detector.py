from typing import Dict, Any, List
from app.core.logging import logger
from app.services.emergency.schemas import EmergencyVerificationResponse

class FakeEmergencyDetector:
    """
    Identifies fake emergency status claims and initiates security actions,
    such as alerts and trust score deductions.
    """
    def is_suspicious_claim(
        self,
        auth_response: EmergencyVerificationResponse,
        trust_score: float,
        ml_prediction: int,
        attack_history: List[str],
        comm_anomaly_detected: bool
    ) -> bool:
        """
        Evaluates check flags to identify if a vehicle is spoofing emergency status.
        """
        # Criteria 1: Authentication failure
        if not auth_response.is_valid:
            return True

        # Criteria 2: Low trust score
        if trust_score < 40.0:
            return True

        # Criteria 3: ML model detects malicious behavior
        if ml_prediction == 1:
            return True

        # Criteria 4: Past attacks record
        if len(attack_history) > 0 and any(a != "NONE" for a in attack_history):
            return True

        # Criteria 5: Abnormal messaging patterns
        if comm_anomaly_detected:
            return True

        return False

    def handle_fake_claim(self, vehicle_id: str, current_trust: float) -> Dict[str, Any]:
        """
        Initiates security alert logging and calculates the trust score deduction.
        """
        logger.warning(f"Fake Emergency Message Detected for vehicle: {vehicle_id}!")
        
        # Calculate trust penalty (50 points deduction for fake emergency claim)
        penalized_trust = max(current_trust - 50.0, 0.0)

        alert_record = {
            "alert_id": f"ALERT_FAKE_{vehicle_id}",
            "vehicle_id": vehicle_id,
            "threat_level": "CRITICAL",
            "description": f"Vehicle claimed emergency status but failed verification. Trust reduced to {penalized_trust}.",
            "alert_status": "RAISED"
        }
        
        return {
            "penalized_trust": penalized_trust,
            "security_alert": alert_record
        }
