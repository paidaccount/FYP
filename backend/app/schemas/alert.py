import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class AlertBase(BaseModel):
    alert_type: str
    message: str
    severity: Optional[str] = "INFO"
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_resolved: Optional[bool] = False

class AlertCreate(AlertBase):
    vehicle_id: Optional[uuid.UUID] = None

class AlertUpdate(BaseModel):
    alert_type: Optional[str] = None
    message: Optional[str] = None
    severity: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    is_resolved: Optional[bool] = None

class AlertResponse(AlertBase):
    id: uuid.UUID
    vehicle_id: Optional[uuid.UUID]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
