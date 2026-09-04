from app.core.logging import logger
from app.services.notification_manager import NotificationManager

class VANETEventListener:
    """
    Listens to system events and forwards notifications.
    """
    def __init__(self, manager: NotificationManager = None):
        self.manager = manager or NotificationManager()

    def on_malicious_detected(
        self, 
        vehicle_id: str, 
        attack_type: str, 
        confidence: float, 
        trust_score: float
    ) -> None:
        logger.info(f"[Event] Malicious vehicle detected: {vehicle_id}")
        self.manager.send_malicious_alert(vehicle_id, attack_type, confidence, trust_score)

    def on_fake_emergency_detected(
        self, 
        vehicle_id: str, 
        reason: str, 
        trust_reduction: float
    ) -> None:
        logger.info(f"[Event] Fake emergency status claim detected from vehicle: {vehicle_id}")
        self.manager.send_fake_emergency_alert(vehicle_id, reason, trust_reduction)

    def on_emergency_approaching(
        self, 
        vehicle_type: str, 
        distance_km: float, 
        direction: str, 
        eta_minutes: float
    ) -> None:
        logger.info(f"[Event] Emergency vehicle approaching: {vehicle_type} at {distance_km}km")
        self.manager.send_emergency_approaching(vehicle_type, distance_km, direction, eta_minutes)

    def on_accident_reported(
        self, 
        accident_id: str, 
        location_desc: str, 
        severity: str, 
        affected_area: float
    ) -> None:
        logger.info(f"[Event] Traffic accident registered: {accident_id}")
        self.manager.send_accident_alert(accident_id, location_desc, severity, affected_area)

    def on_trust_decayed(
        self, 
        vehicle_id: str, 
        previous_score: float, 
        new_score: float, 
        reason: str
    ) -> None:
        logger.info(f"[Event] Vehicle trust score updated: {vehicle_id} ({previous_score} -> {new_score})")
        self.manager.send_trust_update(vehicle_id, previous_score, new_score, reason)

    def on_congestion_detected(self, road_id: str, detour_road: str) -> None:
        logger.info(f"[Event] Congestion alert triggered on edge: {road_id}")
        self.manager.send_traffic_alert(road_id, detour_road)
