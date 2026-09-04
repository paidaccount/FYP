from datetime import datetime
from typing import List, Dict, Any
from app.core.logging import logger
from app.services.emergency.models import AccidentEvent

class AccidentManager:
    """
    Manages active accident zones, maps surrounding vehicle locations,
    and updates traffic congestion levels.
    """
    def __init__(self):
        self.accidents: Dict[str, AccidentEvent] = {}

    def report_accident(
        self, 
        accident_id: str, 
        location: Dict[str, float], 
        severity: str, 
        affected_area: float
    ) -> AccidentEvent:
        """
        Registers a new accident event and flags local traffic zones.
        """
        accident = AccidentEvent(
            id=accident_id,
            location=location,
            severity=severity,
            affected_area=affected_area,
            status="Open",
            timestamp=datetime.utcnow()
        )
        self.accidents[accident_id] = accident
        logger.info(f"Accident logged successfully: {accident_id} | Severity: {severity}")
        return accident

    def identify_nearby_vehicles(
        self, 
        accident_id: str, 
        vehicles_locations: Dict[str, Dict[str, float]]
    ) -> List[str]:
        """
        Identifies vehicles located within the accident's affected radius.
        Uses basic Euclidean distance calculations.
        """
        accident = self.accidents.get(accident_id)
        if not accident:
            return []

        nearby = []
        ax, ay = accident.location["x"], accident.location["y"]
        radius = accident.affected_area

        for veh_id, loc in vehicles_locations.items():
            vx, vy = loc["x"], loc["y"]
            dist = ((ax - vx) ** 2 + (ay - vy) ** 2) ** 0.5
            if dist <= radius:
                nearby.append(veh_id)

        return nearby

    def resolve_accident(self, accident_id: str) -> None:
        """Resolves accident status and clears traffic block flags."""
        if accident_id in self.accidents:
            self.accidents[accident_id].status = "Resolved"
            logger.info(f"Accident resolved: {accident_id}")
