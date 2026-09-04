from typing import List, Dict, Any, Optional
import uuid
from datetime import datetime
from app.services.firebase_service import FirebaseNotificationService
from app.services.notification_templates import NotificationTemplates
from app.database.store import ALERTS # We can use database/in-memory store for saving notification history

# Global list acting as database store for registered device tokens and history
DEVICE_TOKENS: List[Dict[str, Any]] = []
NOTIFICATION_HISTORY: List[Dict[str, Any]] = []

class NotificationManager:
    """
    Manages client target tokens, formats message templates, 
    and handles saving histories.
    """
    def __init__(self, service: FirebaseNotificationService = None):
        self.service = service or FirebaseNotificationService()

    def register_token(self, user_id: str, token: str, platform: str) -> Dict[str, Any]:
        """Registers or updates a device token."""
        # Check if token exists
        for record in DEVICE_TOKENS:
            if record["token"] == token:
                record["user_id"] = user_id
                record["platform"] = platform
                record["updated_at"] = datetime.utcnow().isoformat()
                return record

        new_record = {
            "id": str(uuid.uuid4()),
            "user_id": user_id,
            "token": token,
            "platform": platform,
            "created_at": datetime.utcnow().isoformat()
        }
        DEVICE_TOKENS.append(new_record)
        return new_record

    def get_device_tokens(self, user_id: Optional[str] = None) -> List[str]:
        """Retrieves list of active FCM tokens."""
        if user_id:
            return [d["token"] for d in DEVICE_TOKENS if d["user_id"] == user_id]
        return [d["token"] for d in DEVICE_TOKENS]

    def _log_history(
        self, 
        user_id: str, 
        title: str, 
        message: str, 
        notification_type: str, 
        priority: str
    ) -> Dict[str, Any]:
        """Saves alert payload to notifications log database."""
        record = {
            "id": str(uuid.uuid4()),
            "user_id": user_id,
            "title": title,
            "message": message,
            "notification_type": notification_type,
            "priority": priority,
            "is_read": False,
            "created_at": datetime.utcnow().isoformat()
        }
        NOTIFICATION_HISTORY.append(record)
        return record

    def send_malicious_alert(
        self, 
        vehicle_id: str, 
        attack_type: str, 
        confidence: float, 
        trust_score: float
    ) -> Dict[str, Any]:
        title, body, data = NotificationTemplates.get_malicious_alert(
            vehicle_id, attack_type, confidence, trust_score
        )
        tokens = self.get_device_tokens()
        res = self.service.send_multicast_alert(tokens, title, body, data)
        self._log_history("admin_user", title, body, "SECURITY", "HIGH")
        return res

    def send_fake_emergency_alert(
        self, 
        vehicle_id: str, 
        reason: str, 
        trust_reduction: float
    ) -> Dict[str, Any]:
        title, body, data = NotificationTemplates.get_fake_emergency_alert(
            vehicle_id, reason, trust_reduction
        )
        tokens = self.get_device_tokens()
        res = self.service.send_multicast_alert(tokens, title, body, data)
        self._log_history("admin_user", title, body, "SECURITY", "CRITICAL")
        return res

    def send_emergency_approaching(
        self, 
        vehicle_type: str, 
        distance_km: float, 
        direction: str, 
        eta_minutes: float
    ) -> Dict[str, Any]:
        title, body, data = NotificationTemplates.get_emergency_approaching_alert(
            vehicle_type, distance_km, direction, eta_minutes
        )
        tokens = self.get_device_tokens()
        res = self.service.send_multicast_alert(tokens, title, body, data)
        self._log_history("all_users", title, body, "EMERGENCY", "CRITICAL")
        return res

    def send_accident_alert(
        self, 
        accident_id: str, 
        location_desc: str, 
        severity: str, 
        affected_area: float
    ) -> Dict[str, Any]:
        title, body, data = NotificationTemplates.get_accident_alert(
            accident_id, location_desc, severity, affected_area
        )
        tokens = self.get_device_tokens()
        res = self.service.send_multicast_alert(tokens, title, body, data)
        self._log_history("all_users", title, body, "TRAFFIC", "HIGH")
        return res

    def send_trust_update(
        self, 
        vehicle_id: str, 
        previous_score: float, 
        new_score: float, 
        reason: str
    ) -> Dict[str, Any]:
        title, body, data = NotificationTemplates.get_trust_update_alert(
            vehicle_id, previous_score, new_score, reason
        )
        tokens = self.get_device_tokens()
        res = self.service.send_multicast_alert(tokens, title, body, data)
        self._log_history("all_users", title, body, "TRUST", "MEDIUM")
        return res

    def send_traffic_alert(self, road_id: str, detour_road: str) -> Dict[str, Any]:
        title, body, data = NotificationTemplates.get_traffic_alert(road_id, detour_road)
        tokens = self.get_device_tokens()
        res = self.service.send_multicast_alert(tokens, title, body, data)
        self._log_history("all_users", title, body, "TRAFFIC", "MEDIUM")
        return res
