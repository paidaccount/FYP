import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class EmergencyVehicleBase(BaseModel):
    department: str
    certification_expiry: datetime
    authorization_status: Optional[str] = "PENDING"
    priority_level: Optional[int] = 1

class EmergencyVehicleCreate(EmergencyVehicleBase):
    vehicle_id: uuid.UUID

class EmergencyVehicleUpdate(BaseModel):
    department: Optional[str] = None
    certification_expiry: Optional[datetime] = None
    authorization_status: Optional[str] = None
    priority_level: Optional[int] = None

class EmergencyVehicleResponse(EmergencyVehicleBase):
    id: uuid.UUID
    vehicle_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
