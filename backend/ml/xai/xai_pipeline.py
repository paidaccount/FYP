import uuid
from datetime import datetime
import pandas as pd
from typing import Dict, Any, List
from app.core.logging import logger
from app.services.xai.shap_explainer import SHAPExplainerWrapper
from app.services.xai.lime_explainer import LIMEExplainerWrapper
from app.services.xai.explanation_generator import ExplanationGenerator
from app.services.xai.visualization import XAIVisualizer

class XAIPipeline:
    """
    Coordinates Explainable AI pipeline:
    Instance -> Prediction -> SHAP analysis -> LIME analysis -> NLP Translation -> Plot Output.
    """
    def __init__(
        self, 
        model: Any, 
        background_data: pd.DataFrame,
        generator: ExplanationGenerator = None,
        visualizer: XAIVisualizer = None
    ):
        self.model = model
        self.background_data = background_data
        self.generator = generator or ExplanationGenerator()
        self.visualizer = visualizer or XAIVisualizer()
        
        # Instantiate wrappers
        self.shap_wrapper = SHAPExplainerWrapper(model, background_data)
        self.lime_wrapper = LIMEExplainerWrapper(model, background_data)

    def explain_instance(self, instance_df: pd.DataFrame, vehicle_id: str) -> Dict[str, Any]:
        """
        Runs prediction and extracts local explanations. Saves charts and return JSON schema.
        """
        prediction_uuid = str(uuid.uuid4())
        logger.info(f"Initiating XAI explanation pipeline for vehicle: {vehicle_id} (ID: {prediction_uuid})")

        # 1. Prediction and metrics
        probs = self.model.predict_proba(instance_df)[0]
        pred_label = int(self.model.predict(instance_df)[0])
        confidence = float(probs[pred_label])

        prediction_text = "Malicious Vehicle" if pred_label == 1 else "Normal Vehicle"

        # 2. Extract SHAP explanations
        shap_details = self.shap_wrapper.explain_instance(instance_df)
        shap_vals = shap_details["shap_values"]
        base_value = shap_details["base_value"]

        # 3. Extract LIME explanations
        lime_details = self.lime_wrapper.explain_instance(instance_df)
        lime_vals = lime_details["lime_values"]
        lime_exp_obj = lime_details["lime_explanation_object"]

        # 4. Generate Semantic reason
        reason = self.generator.generate_local_reason(
            prediction=pred_label,
            confidence=confidence,
            shap_values=shap_vals,
            lime_values=lime_vals
        )

        # 5. Save Plots
        instance_dict = instance_df.to_dict(orient="records")[0]
        
        # Only save plots for malicious detections or interesting anomalies to save space
        self.visualizer.save_shap_plots(prediction_uuid, shap_vals, base_value, instance_dict)
        self.visualizer.save_lime_plots(prediction_uuid, lime_exp_obj)

        # 6. Extract top contributing features (LIME weights > 0.05 or positive SHAP)
        important_features = []
        for feat, val in lime_vals.items():
            if abs(val) > 0.03:
                important_features.append(feat)

        explanation_record = {
            "prediction_id": prediction_uuid,
            "vehicle_id": vehicle_id,
            "prediction": prediction_text,
            "confidence": confidence,
            "important_features": important_features,
            "shap_values": shap_vals,
            "lime_values": lime_vals,
            "generated_reason": reason,
            "timestamp": datetime.utcnow().isoformat()
        }

        logger.info(f"XAI pipeline completed for vehicle {vehicle_id}. Result: {prediction_text} ({confidence*100:.1f}%)")
        return explanation_record
