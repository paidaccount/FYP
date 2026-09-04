from pydantic import BaseModel, Field
from typing import Dict, Optional

class EmergencyVerificationRequest(BaseModel):
    vehicle_id: str
    emergency_type: str # Ambulance, Police, Fire Brigade, Rescue
    authorization_token: str
    digital_identity: str

class EmergencyVerificationResponse(BaseModel):
    is_valid: bool
    status: str # Authenticated Emergency Vehicle / Fake Emergency Claim
    reason: str

class PriorityCalculationRequest(BaseModel):
    vehicle_id: str
    vehicle_type: str
    distance: float # km
    trust_score: float
    traffic_condition: str # Light, Medium, Heavy
    road_availability: bool
    accident_severity: Optional[str] = "NONE" # NONE, Low, Medium, High, Critical

class PriorityCalculationResponse(BaseModel):
    vehicle_id: str
    priority_level: str # Critical, High, Medium, Low
    priority_score: float
