from typing import Dict, Any

class TrafficAnalyzer:
    """
    Evaluates road congestion classifications (Low, Medium, Heavy) and congestion scores
    based on raw telemetry attributes.
    """
    def analyze_traffic(self, density: float) -> Dict[str, Any]:
        """
        Maps congestion density (0-100 scale) to discrete levels.
        """
        score = max(0.0, min(100.0, density))

        if score < 30.0:
            level = "Low Traffic"
        elif score < 70.0:
            level = "Medium Traffic"
        else:
            level = "Heavy Traffic"

        return {
            "traffic_level": level,
            "traffic_score": score
        }
