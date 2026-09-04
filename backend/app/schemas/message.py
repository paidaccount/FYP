import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class VehicleMessageBase(BaseModel):
    latitude: float
    longitude: float
    speed: float
    heading: float
    timestamp: datetime
    message_type: str = "BSM"
    signature: str

class VehicleMessageCreate(VehicleMessageBase):
    vehicle_id: uuid.UUID

class VehicleMessageUpdate(BaseModel):
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    speed: Optional[float] = None
    heading: Optional[float] = None
    timestamp: Optional[datetime] = None
    message_type: Optional[str] = None
    signature: Optional[str] = None

class VehicleMessageResponse(VehicleMessageBase):
    id: uuid.UUID
    vehicle_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
