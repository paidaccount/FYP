from typing import Dict, Any, Tuple

class NotificationTemplates:
    """
    Renders standardized title, body, and data maps for VANET event alerts.
    """
    @staticmethod
    def get_malicious_alert(
        vehicle_id: str, 
        attack_type: str, 
        confidence: float, 
        trust_score: float
    ) -> Tuple[str, str, Dict[str, str]]:
        title = "Malicious Vehicle Detected"
        body = f"Vehicle {vehicle_id} detected with {attack_type}."
        data = {
            "notification_type": "SECURITY",
            "vehicle_id": vehicle_id,
            "attack_type": attack_type,
            "confidence": f"{confidence:.1f}%",
            "trust_score": f"{trust_score:.2f}",
            "priority": "HIGH"
        }
        return title, body, data

    @staticmethod
    def get_fake_emergency_alert(
        vehicle_id: str, 
        reason: str, 
        trust_reduction: float
    ) -> Tuple[str, str, Dict[str, str]]:
        title = "Fake Emergency Detected"
        body = f"Unauthorized emergency claim detected from Vehicle {vehicle_id}."
        data = {
            "notification_type": "SECURITY",
            "vehicle_id": vehicle_id,
            "reason": reason,
            "trust_reduction": f"-{trust_reduction:.2f}",
            "priority": "CRITICAL"
        }
        return title, body, data

    @staticmethod
    def get_emergency_approaching_alert(
        vehicle_type: str, 
        distance_km: float, 
        direction: str, 
        eta_minutes: float
    ) -> Tuple[str, str, Dict[str, str]]:
        title = "Emergency Vehicle Approaching"
        body = f"{vehicle_type} approaching. Please give way."
        data = {
            "notification_type": "EMERGENCY",
            "vehicle_type": vehicle_type,
            "distance_km": f"{distance_km:.1f}",
            "direction": direction,
            "eta_minutes": f"{eta_minutes:.1f}",
            "priority": "CRITICAL"
        }
        return title, body, data

    @staticmethod
    def get_accident_alert(
        accident_id: str, 
        location_desc: str, 
        severity: str, 
        affected_area: float
    ) -> Tuple[str, str, Dict[str, str]]:
        title = "Accident Ahead"
        body = f"Accident detected on {location_desc}."
        data = {
            "notification_type": "TRAFFIC",
            "accident_id": accident_id,
            "severity": severity.upper(),
            "affected_area": f"{affected_area}m",
            "priority": "HIGH"
        }
        return title, body, data

    @staticmethod
    def get_trust_update_alert(
        vehicle_id: str, 
        previous_score: float, 
        new_score: float, 
        reason: str
    ) -> Tuple[str, str, Dict[str, str]]:
        title = "Vehicle Trust Updated"
        body = f"Vehicle {vehicle_id} trust reduced to suspicious."
        data = {
            "notification_type": "TRUST",
            "vehicle_id": vehicle_id,
            "previous_score": f"{previous_score:.2f}",
            "new_score": f"{new_score:.2f}",
            "reason": reason,
            "priority": "MEDIUM"
        }
        return title, body, data

    @staticmethod
    def get_traffic_alert(road_id: str, recommended_detour: str) -> Tuple[str, str, Dict[str, str]]:
        title = "Heavy Traffic Ahead"
        body = f"Alternative route recommended via {recommended_detour}."
        data = {
            "notification_type": "TRAFFIC",
            "road_id": road_id,
            "recommended_detour": recommended_detour,
            "priority": "MEDIUM"
        }
        return title, body, data
