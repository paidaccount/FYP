import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class ReportBase(BaseModel):
    incident_description: str
    latitude: float
    longitude: float

class ReportCreate(ReportBase):
    reporter_vehicle_id: uuid.UUID
    target_vehicle_id: Optional[uuid.UUID] = None

class ReportUpdate(BaseModel):
    incident_description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    target_vehicle_id: Optional[uuid.UUID] = None

class ReportResponse(ReportBase):
    id: uuid.UUID
    reporter_vehicle_id: uuid.UUID
    target_vehicle_id: Optional[uuid.UUID]
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
