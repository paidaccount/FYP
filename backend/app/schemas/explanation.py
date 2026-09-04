import uuid
from datetime import datetime
from typing import Any, Dict, Optional
from pydantic import BaseModel, ConfigDict

class AIExplanationBase(BaseModel):
    explainer_type: str
    explanation_payload_json: Dict[str, Any]

class AIExplanationCreate(AIExplanationBase):
    prediction_id: uuid.UUID

class AIExplanationUpdate(BaseModel):
    explainer_type: Optional[str] = None
    explanation_payload_json: Optional[Dict[str, Any]] = None

class AIExplanationResponse(AIExplanationBase):
    id: uuid.UUID
    prediction_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
