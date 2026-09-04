import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict, Field

class VehicleBase(BaseModel):
    license_plate: str = Field(..., max_length=50)
    vehicle_type: str = Field(..., max_length=50)
    cert_hash: str = Field(..., max_length=64)
    public_key: str

class VehicleCreate(VehicleBase):
    owner_id: Optional[uuid.UUID] = None

class VehicleUpdate(BaseModel):
    license_plate: Optional[str] = None
    vehicle_type: Optional[str] = None
    status: Optional[str] = None
    cert_hash: Optional[str] = None
    public_key: Optional[str] = None
    trust_score: Optional[float] = None

class VehicleResponse(VehicleBase):
    id: uuid.UUID
    owner_id: Optional[uuid.UUID]
    status: str
    trust_score: float
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
