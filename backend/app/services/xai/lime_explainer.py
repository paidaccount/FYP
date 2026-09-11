import importlib
import pandas as pd
import numpy as np
from typing import Dict, Any, List
from app.core.logging import logger

try:
    _lime_tab = importlib.import_module("lime.lime_tabular")
    LimeTabularExplainer = getattr(_lime_tab, "LimeTabularExplainer")
    LIME_AVAILABLE = True
except (ImportError, AttributeError):
    LimeTabularExplainer = None
    LIME_AVAILABLE = False

class LIMEExplainerWrapper:
    """
    Wrapper mapping input instances to LIME (Local Interpretable Model-agnostic 
    Explanations) linear regression weights.
    """
    def __init__(self, model: Any, training_data: pd.DataFrame):
        self.model = model
        self.feature_names = list(training_data.columns)
        self.training_data = training_data
        if LIME_AVAILABLE:
            self.explainer = LimeTabularExplainer(
                training_data=np.array(training_data),
                feature_names=self.feature_names,
                class_names=["Normal", "Malicious"],
                mode="classification"
            )
        else:
            self.explainer = None
            logger.info("LIME package not installed. Utilizing built-in local linear perturbation surrogate.")

    def explain_instance(self, instance: pd.DataFrame) -> Dict[str, Any]:
        """
        Generates local perturbation explanation for a single telemetry record.
        """
        if self.explainer is not None and LIME_AVAILABLE:
            # Convert 1-row DataFrame to 1D numpy array
            row_vector = np.array(instance).flatten()

            # Run explanation
            exp = self.explainer.explain_instance(
                data_row=row_vector,
                predict_fn=self.model.predict_proba,
                num_features=len(self.feature_names)
            )

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
        else:
            # Fallback local perturbation weights
            row_vector = np.array(instance).flatten()
            probs = self.model.predict_proba(instance)[0]
            base_prob = float(probs[1])
            
            stds = self.training_data.std().values
            stds = np.where(stds == 0, 1.0, stds)
            
            lime_weights = {}
            num_samples = 20
            
            for idx, feat_name in enumerate(self.feature_names):
                pert_plus = np.tile(row_vector, (num_samples, 1))
                noise = np.random.normal(0, stds[idx] * 0.1, size=num_samples)
                pert_plus[:, idx] += noise
                
                df_pert = pd.DataFrame(pert_plus, columns=self.feature_names)
                pred_pert = self.model.predict_proba(df_pert)[:, 1]
                weight = float(np.mean(pred_pert) - base_prob)
                lime_weights[feat_name] = weight

            return {
                "lime_values": lime_weights,
                "lime_explanation_object": None
            }
