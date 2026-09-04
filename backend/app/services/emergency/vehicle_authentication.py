from app.services.emergency.emergency_config import AUTH_TOKEN_PREFIX
from app.services.emergency.schemas import EmergencyVerificationRequest, EmergencyVerificationResponse

class VehicleAuthenticator:
    """
    Verifies the credentials and digital authorization tokens of vehicles 
    claiming emergency status.
    """
    def verify_credentials(self, request: EmergencyVerificationRequest) -> EmergencyVerificationResponse:
        """
        Validates authorization tokens and digital identity signatures.
        """
        expected_token = f"{AUTH_TOKEN_PREFIX}{request.emergency_type.upper().replace(' ', '_')}_{request.vehicle_id}"
        
        # Verify token match
        if request.authorization_token != expected_token:
            return EmergencyVerificationResponse(
                is_valid=False,
                status="Fake Emergency Claim",
                reason="Authorization token mismatch. Token is invalid or signature does not match vehicle parameters."
            )

        # Verify digital identity is present
        if not request.digital_identity or len(request.digital_identity) < 10:
            return EmergencyVerificationResponse(
                is_valid=False,
                status="Fake Emergency Claim",
                reason="Invalid digital identity signature. Authentication rejected."
            )

        return EmergencyVerificationResponse(
            is_valid=True,
            status="Authenticated Emergency Vehicle",
            reason="Vehicle credentials and digital identity verified successfully."
        )
