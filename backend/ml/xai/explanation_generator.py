from typing import Dict, Any, List
from app.services.xai.feature_interpreter import FeatureInterpreter

class ExplanationGenerator:
    """
    Translates numeric SHAP/LIME contribution vectors and prediction statuses
    into natural, operator-friendly explanatory paragraphs.
    """
    def __init__(self, interpreter: FeatureInterpreter = None):
        self.interpreter = interpreter or FeatureInterpreter()

    def generate_local_reason(
        self, 
        prediction: int, 
        confidence: float, 
        shap_values: Dict[str, float], 
        lime_values: Dict[str, float]
    ) -> str:
        """
        Converts classification outcomes and top feature metrics into a sentence.
        """
        # If prediction indicates normal behavior (0)
        if prediction == 0:
            return "Vehicle behavior is normal. No significant anomalies detected."

        # Filter features that increase the probability of malicious classification (positive values)
        # Combine SHAP and LIME to select the most significant contributors
        contributing_factors = []
        for feature, val in lime_values.items():
            if val > 0.01: # Filter trace noise contributions
                contributing_factors.append((feature, val))

        # Sort by weight contribution desc
        contributing_factors.sort(key=lambda x: x[1], reverse=True)

        if not contributing_factors:
            # Fallback to SHAP values if LIME values are too low
            for feature, val in shap_values.items():
                if val > 0.0:
                    contributing_factors.append((feature, val))
            contributing_factors.sort(key=lambda x: x[1], reverse=True)

        # Select top 3 contributing factors
        top_factors = contributing_factors[:3]

        if not top_factors:
            return (
                f"The vehicle was classified as malicious (confidence: {confidence*100:.1f}%) "
                "due to minor anomalies across multiple kinematic and communication features."
            )

        # Translate feature columns into semantic descriptions
        phrases = []
        for feat_name, _ in top_factors:
            # Customized descriptions for attack scenarios
            if feat_name in ["position_anomaly_score", "GPS_consistency"]:
                phrases.append("inconsistent GPS movement")
            elif feat_name in ["speed_anomaly_score", "speed_change_rate"]:
                phrases.append("abnormal speed changes")
            elif feat_name in ["message_frequency", "message_frequency_anomaly"]:
                phrases.append("unusually high communication frequency")
            elif feat_name in ["acceleration_anomaly", "acceleration"]:
                phrases.append("abnormal acceleration patterns")
            elif feat_name == "trajectory_deviation":
                phrases.append("suspicious movement trajectories")
            else:
                phrases.append(self.interpreter.interpret(feat_name).lower())

        # Construct final sentence representation
        if len(phrases) == 1:
            reasons_str = phrases[0]
        elif len(phrases) == 2:
            reasons_str = f"{phrases[0]} and {phrases[1]}"
        else:
            reasons_str = f"{phrases[0]}, {phrases[1]}, and {phrases[2]}"

        reason = (
            f"The vehicle was detected as malicious because "
            f"it showed {reasons_str}."
        )
        return reason
