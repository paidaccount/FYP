from typing import Dict, Any

# Map emergency type to default priority status
VEHICLE_BASE_PRIORITY: Dict[str, str] = {
    "AMBULANCE": "High",
    "FIRE BRIGADE": "High",
    "POLICE": "Medium",
    "RESCUE": "Medium"
}

class EmergencyRules:
    """
    Applies overrides based on vehicle authentication
    and warning statuses.
    """
    @staticmethod
    def get_base_priority(vehicle_type: str) -> str:
        """Resolves base priority category for a specific vehicle type."""
        return VEHICLE_BASE_PRIORITY.get(vehicle_type.upper(), "Medium")

    @staticmethod
    def get_traffic_adjustment(traffic_condition: str) -> float:
        """Resolves multiplier adjustments based on traffic condition names."""
        traffic = traffic_condition.upper()
        if traffic == "HEAVY":
            return 2.5
        elif traffic == "MEDIUM":
            return 1.5
        else:
            return 1.0
