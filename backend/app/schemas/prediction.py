import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class PredictionBase(BaseModel):
    is_malicious: bool
    probability: float
    model_version: str

class PredictionCreate(PredictionBase):
    message_id: uuid.UUID

class PredictionUpdate(BaseModel):
    is_malicious: Optional[bool] = None
    probability: Optional[float] = None
    model_version: Optional[str] = None

class PredictionResponse(PredictionBase):
    id: uuid.UUID
    message_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
