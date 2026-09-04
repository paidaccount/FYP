from typing import Dict

# Semantic mappings of raw feature names to human-comprehensible descriptions
FEATURE_SEMANTIC_MAP: Dict[str, str] = {
    "speed": "Reported vehicle velocity",
    "acceleration": "Reported acceleration",
    "heading": "Reported heading",
    "lane_position": "Lane index position",
    "message_frequency": "Unusual communication frequency",
    "message_interval": "Message interval delta timing",
    "neighbor_count": "Local vehicle density (neighbor count)",
    "communication_rate": "Message beaconing frequency",
    "packet_count": "Historical packet sequence count",
    "speed_change_rate": "Sudden speed variation",
    "position_change_rate": "Displacement speed mapping",
    "distance_difference": "GPS displacement distance",
    "trajectory_consistency": "Trajectory consistency matching",
    "message_consistency": "Message payload consistency verification",
    "GPS_consistency": "GPS location inconsistency",
    "speed_anomaly_score": "Abrupt velocity deviation",
    "position_anomaly_score": "GPS coordinate displacement inconsistency",
    "message_frequency_anomaly": "Unusual communication frequency",
    "acceleration_anomaly": "Abnormal acceleration pattern",
    "trajectory_deviation": "Suspicious movement trajectory",
    "communication_behavior_score": "Communication transmission density score"
}

class FeatureInterpreter:
    """
    Translates raw database feature codes and variables 
    into semantically rich, operator-readable descriptions.
    """
    def __init__(self, semantic_map: Dict[str, str] = FEATURE_SEMANTIC_MAP):
        self.semantic_map = semantic_map

    def interpret(self, feature_name: str) -> str:
        """
        Retrieves human-readable description for a raw feature column name.
        """
        return self.semantic_map.get(feature_name, f"Feature ({feature_name})")
