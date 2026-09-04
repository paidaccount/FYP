from app.services.trust_config import TRUSTED_THRESHOLD, SUSPICIOUS_THRESHOLD

class TrustUpdater:
    """
    Updates classification status tags based on final composite trust scores.
    """
    @staticmethod
    def resolve_status(score: float) -> str:
        """Maps trust scores into vehicle status tags."""
        if score >= TRUSTED_THRESHOLD:
            return "Trusted Vehicle"
        elif score >= SUSPICIOUS_THRESHOLD:
            return "Suspicious Vehicle"
        else:
            return "Untrusted Vehicle"
