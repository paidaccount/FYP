import uuid
from datetime import datetime
from typing import Optional
from pydantic import BaseModel, ConfigDict

class NotificationHistoryBase(BaseModel):
    title: str
    body: str
    notification_type: str
    is_read: Optional[bool] = False

class NotificationHistoryCreate(NotificationHistoryBase):
    user_id: uuid.UUID

class NotificationHistoryUpdate(BaseModel):
    title: Optional[str] = None
    body: Optional[str] = None
    notification_type: Optional[str] = None
    is_read: Optional[bool] = None

class NotificationHistoryResponse(NotificationHistoryBase):
    id: uuid.UUID
    user_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
