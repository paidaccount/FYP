from lime.lime_tabular import LimeTabularExplainer
import pandas as pd
import numpy as np
from typing import Dict, Any, List
from app.core.logging import logger

class LIMEExplainerWrapper:
    """
    Wrapper mapping input instances to LIME (Local Interpretable Model-agnostic 
    Explanations) linear regression weights.
    """
    def __init__(self, model: Any, training_data: pd.DataFrame):
        self.model = model
        self.feature_names = list(training_data.columns)
        self.explainer = LimeTabularExplainer(
            training_data=np.array(training_data),
            feature_names=self.feature_names,
            class_names=["Normal", "Malicious"],
            mode="classification"
        )

    def explain_instance(self, instance: pd.DataFrame) -> Dict[str, Any]:
        """
        Generates local perturbation explanation for a single telemetry record.
        """
        # Convert 1-row DataFrame to 1D numpy array
        row_vector = np.array(instance).flatten()

        # Run explanation
        exp = self.explainer.explain_instance(
            data_row=row_vector,
            predict_fn=self.model.predict_proba,
            num_features=len(self.feature_names)
        )

        # LIME as_map() returns class_index -> list of (feature_index, weight)
        # Class index 1 represents Malicious
        map_details = exp.as_map()
        positive_class_idx = 1
        
        lime_weights = {}
        if positive_class_idx in map_details:
            for feat_idx, weight in map_details[positive_class_idx]:
                feat_name = self.feature_names[feat_idx]
                lime_weights[feat_name] = float(weight)

        return {
            "lime_values": lime_weights,
            "lime_explanation_object": exp
        }
