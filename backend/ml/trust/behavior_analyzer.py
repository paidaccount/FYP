from typing import Dict, Any

class BehaviorAnalyzer:
    """
    Evaluates kinematic and communication consistency scores
    based on raw telemetry variables and anomaly indicators.
    """
    def analyze_speed_consistency(self, features: Dict[str, Any]) -> float:
        """Evaluates speed profile correctness (0 to 100)."""
        anomaly = features.get("speed_anomaly_score", 0.0)
        # If anomaly is standard-scaled, values above 2.0 indicate deviations
        if anomaly > 0.0:
            penalty = min(anomaly * 20.0, 100.0)
            return max(100.0 - penalty, 0.0)
        return 100.0

    def analyze_position_consistency(self, features: Dict[str, Any]) -> float:
        """Evaluates spatial displacement consistency (0 to 100)."""
        anomaly = features.get("position_anomaly_score", 0.0)
        gps_incon = features.get("GPS_consistency", 0.0)
        
        max_deviation = max(anomaly, gps_incon)
        if max_deviation > 0.0:
            penalty = min(max_deviation * 20.0, 100.0)
            return max(100.0 - penalty, 0.0)
        return 100.0

    def analyze_communication_behavior(self, features: Dict[str, Any]) -> float:
        """Evaluates communication beacon intervals frequency (0 to 100)."""
        freq_anomaly = features.get("message_frequency_anomaly", 0.0)
        comm_score = features.get("communication_behavior_score", 0.0)

        if freq_anomaly > 0.0 or comm_score > 2.0:
            penalty = max(freq_anomaly * 50.0, comm_score * 10.0)
            return max(100.0 - penalty, 0.0)
        return 100.0
