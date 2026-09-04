from app.services.emergency.emergency_config import VEHICLE_SPEEDS

class ETACalculator:
    """
    Evaluates arrival times for emergency vehicles based on type velocities,
    distances, and traffic scaling multipliers.
    """
    def calculate_eta(
        self, 
        distance_km: float, 
        vehicle_type: str, 
        traffic_condition: str
    ) -> float:
        """
        Calculates ETA in minutes.
        """
        # Resolve speed in m/s (default to standard 15 m/s)
        speed_ms = VEHICLE_SPEEDS.get(vehicle_type, VEHICLE_SPEEDS["Standard"])

        # Convert distance to meters
        distance_meters = distance_km * 1000.0

        # Calculate base travel time in seconds
        base_time_seconds = distance_meters / speed_ms

        # Apply traffic multipliers
        traffic = traffic_condition.upper()
        if traffic == "HEAVY":
            multiplier = 2.5
        elif traffic == "MEDIUM":
            multiplier = 1.5
        else: # LIGHT
            multiplier = 1.0

        total_time_seconds = base_time_seconds * multiplier

        # Convert to minutes and round to 1 decimal place
        eta_minutes = total_time_seconds / 60.0
        return round(eta_minutes, 1)
