from typing import List, Dict, Any
import importlib

try:
    messaging = importlib.import_module("firebase_admin.messaging")
except ImportError:
    messaging = None

from app.core.logging import logger
from app.services.firebase_config import initialize_firebase, firebase_initialized

class FirebaseNotificationService:
    """
    Wrapper for sending Firebase Cloud Messages (FCM) to target devices.
    Supports single token dispatches and multicast messages.
    """
    def __init__(self):
        initialize_firebase()

    def send_multicast_alert(
        self, 
        tokens: List[str], 
        title: str, 
        body: str, 
        data: Dict[str, str]
    ) -> Dict[str, Any]:
        """
        Dispatches a notification multicast to a list of client device tokens.
        """
        if not tokens:
            return {"success_count": 0, "failure_count": 0, "status": "NO_TOKENS"}

        # If not initialized, log payload and run in mock sandboxed mode
        if not firebase_initialized:
            logger.info(
                f"[MOCK FCM] Dispatched alert to {len(tokens)} tokens:\n"
                f"  Title: {title}\n"
                f"  Body: {body}\n"
                f"  Data Payload: {data}"
            )
            return {"success_count": len(tokens), "failure_count": 0, "status": "MOCK_SUCCESS"}

        try:
            # Build FCM multicast payload
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data,
                tokens=tokens
            )
            
            response = messaging.send_multicast(message)
            logger.info(
                f"FCM multicast complete: {response.success_count} success, "
                f"{response.failure_count} failures."
            )
            return {
                "success_count": response.success_count,
                "failure_count": response.failure_count,
                "status": "SENT"
            }
        except Exception as e:
            logger.error(f"FCM multicast dispatch failed: {str(e)}")
            return {"success_count": 0, "failure_count": len(tokens), "status": "ERROR", "error": str(e)}
