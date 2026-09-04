import shap
import pandas as pd
import numpy as np
from typing import Dict, Any, List
from app.core.logging import logger

class SHAPExplainerWrapper:
    """
    Wrapper mapping model classification instances to SHAP values.
    Identifies tree-based structures to load TreeExplainer, falling back
    to sampling-based KernelExplainer configurations.
    """
    def __init__(self, model: Any, background_data: pd.DataFrame = None):
        self.model = model
        self.background_data = background_data
        self.explainer = None
        self._init_explainer()

    def _init_explainer(self) -> None:
        model_type = self.model.__class__.__name__
        logger.info(f"Detecting model framework: {model_type} for SHAP initialization.")

        # TreeExplainer is compatible with gradient boosted trees and random forest
        if model_type in ["XGBClassifier", "RandomForestClassifier", "LGBMClassifier", "CatBoostClassifier"]:
            try:
                # TreeExplainer checks
                self.explainer = shap.TreeExplainer(self.model)
                return
            except Exception as e:
                logger.warning(f"TreeExplainer failed to initialize ({str(e)}). Falling back to KernelExplainer.")

        # Fallback to KernelExplainer
        if self.background_data is not None:
            # Downsample background data to speed up KernelExplainer execution
            sample_data = self.background_data
            if len(self.background_data) > 20:
                sample_data = shap.sample(self.background_data, 20)
            
            # KernelExplainer wraps the probability function
            self.explainer = shap.KernelExplainer(self.model.predict_proba, sample_data)
        else:
            raise ValueError("Background training data is required to run KernelExplainer fallback.")

    def explain_instance(self, instance: pd.DataFrame) -> Dict[str, Any]:
        """
        Computes local SHAP values for a single prediction telemetry row.
        """
        probs = self.model.predict_proba(instance)[0]
        prediction = int(self.model.predict(instance)[0])
        confidence = float(probs[prediction])

        # Compute SHAP values
        raw_shap = self.explainer.shap_values(instance)

        # Handle list structure (multi-class or binary lists)
        if isinstance(raw_shap, list):
            # Use positive class contributions
            raw_shap = raw_shap[1] if len(raw_shap) > 1 else raw_shap[0]
        elif len(raw_shap.shape) == 3: # Multi-class tensor output shape [samples, features, classes]
            raw_shap = raw_shap[:, :, 1]
            
        shap_flat = np.array(raw_shap).flatten()

        # Map feature names to contributions
        shap_vals_map = {
            col: float(val) 
            for col, val in zip(instance.columns, shap_flat)
        }

        # Resolve base values
        expected_val = self.explainer.expected_value
        if isinstance(expected_val, (list, np.ndarray)):
            expected_val = expected_val[1] if len(expected_val) > 1 else expected_val[0]

        return {
            "prediction": prediction,
            "confidence": confidence,
            "shap_values": shap_vals_map,
            "base_value": float(expected_val),
            "raw_shap_matrix": raw_shap
        }
