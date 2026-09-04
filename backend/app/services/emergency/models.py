from datetime import datetime
from typing import List, Dict, Any, Optional
from pydantic import BaseModel, Field

class EmergencyVehicle(BaseModel):
    """Data representation of the EmergencyVehicle entity."""
    id: str
    vehicle_id: str
    vehicle_type: str # Ambulance, Police, Fire Brigade, Rescue
    authorization_id: str
    registration_number: str
    operator_name: str
    status: str # Active, Inactive, Dispatched
    location: Dict[str, float] # {"x": float, "y": float}
    destination: Optional[Dict[str, float]] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

class AccidentEvent(BaseModel):
    """Data representation of the AccidentEvent entity."""
    id: str
    location: Dict[str, float] # {"x": float, "y": float}
    severity: str # Critical, High, Medium, Low
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    affected_area: float # Radius in meters
    status: str # Open, Under Control, Resolved

class EmergencyAlert(BaseModel):
    """Data representation of the EmergencyAlert sent to surrounding vehicles."""
    id: str
    alert_type: str
    vehicle_id: str
    distance: float # km
    direction: float # degrees
    eta_minutes: float
    priority_level: str # Critical, High, Medium, Low
    timestamp: datetime = Field(default_factory=datetime.utcnow)

class EmergencyHistory(BaseModel):
    """Data representation of the EmergencyHistory log."""
    id: str
    vehicle_id: str
    event_type: str # Authenticated, Fake Claim, Priority Alert, Route Assist
    description: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
