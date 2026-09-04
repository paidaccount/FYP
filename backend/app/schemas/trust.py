import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class TrustScoreBase(BaseModel):
    score: float
    update_reason: str

class TrustScoreCreate(TrustScoreBase):
    vehicle_id: uuid.UUID

class TrustScoreUpdate(BaseModel):
    score: Optional[float] = None
    update_reason: Optional[str] = None

class TrustScoreResponse(TrustScoreBase):
    id: uuid.UUID
    vehicle_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
