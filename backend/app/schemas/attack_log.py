import uuid
from datetime import datetime
from typing import Any, Dict, Optional
from pydantic import BaseModel, ConfigDict

class AttackLogBase(BaseModel):
    detected_attack_type: str
    evidence_data_json: Dict[str, Any]

class AttackLogCreate(AttackLogBase):
    offender_vehicle_id: uuid.UUID

class AttackLogUpdate(BaseModel):
    detected_attack_type: Optional[str] = None
    evidence_data_json: Optional[Dict[str, Any]] = None

class AttackLogResponse(AttackLogBase):
    id: uuid.UUID
    offender_vehicle_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
