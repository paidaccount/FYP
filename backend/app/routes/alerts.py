from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import Dict, Any, List
from app.services.notification_manager import NotificationManager, NOTIFICATION_HISTORY

router = APIRouter()

class TokenRegisterSchema(BaseModel):
    user_id: str
    token: str
    platform: str = Field("android", description="android, ios, or web")

class ReadNotificationResponse(BaseModel):
    success: bool
    message: str

@router.post("/register-token", status_code=status.HTTP_201_CREATED)
def register_device_token(payload: TokenRegisterSchema):
    if not payload.token or not payload.user_id:
        raise HTTPException(status_code=400, detail="Token and user_id fields cannot be empty.")
        
    manager = NotificationManager()
    record = manager.register_token(
        user_id=payload.user_id,
        token=payload.token,
        platform=payload.platform
    )
    return {"message": "Device token registered successfully", "record": record}

@router.get("/history")
def get_notification_history():
    # Return history, sorted descending by created_at timestamp
    history = list(NOTIFICATION_HISTORY)
    history.sort(key=lambda x: x["created_at"], reverse=True)
    return history

@router.put("/read/{id}", response_model=ReadNotificationResponse)
def mark_notification_as_read(id: str):
    found = False
    for item in NOTIFICATION_HISTORY:
        if item["id"] == id:
            item["is_read"] = True
            found = True
            break
            
    if not found:
        raise HTTPException(status_code=404, detail="Notification ID not found.")
        
    return ReadNotificationResponse(
        success=True,
        message="Notification marked as read successfully."
    )
