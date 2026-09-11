try:
    import shap
    SHAP_AVAILABLE = True
except ImportError:
    SHAP_AVAILABLE = False

import pandas as pd
import numpy as np
from typing import Dict, Any, List
from app.core.logging import logger

class SHAPExplainerWrapper:
    """
    Wrapper mapping model classification instances to SHAP values.
    Identifies tree-based structures to load TreeExplainer, falling back
    to sampling-based KernelExplainer configurations or tree attribution heuristics.
    """
    def __init__(self, model: Any, background_data: pd.DataFrame = None):
        self.model = model
        self.background_data = background_data
        self.explainer = None
        self._init_explainer()

    def _init_explainer(self) -> None:
        if not SHAP_AVAILABLE:
            logger.info("SHAP package not installed. Utilizing built-in tree feature attribution engine.")
            return

        model_type = self.model.__class__.__name__
        logger.info(f"Detecting model framework: {model_type} for SHAP initialization.")

        # TreeExplainer is compatible with gradient boosted trees and random forest
        if model_type in ["XGBClassifier", "RandomForestClassifier", "LGBMClassifier", "CatBoostClassifier"]:
            try:
                self.explainer = shap.TreeExplainer(self.model)
                return
            except Exception as e:
                logger.warning(f"TreeExplainer failed to initialize ({str(e)}). Falling back to KernelExplainer.")

        # Fallback to KernelExplainer
        if self.background_data is not None:
            sample_data = self.background_data
            if len(self.background_data) > 20:
                sample_data = shap.sample(self.background_data, 20)
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

        if self.explainer is not None and SHAP_AVAILABLE:
            # Compute SHAP values
            raw_shap = self.explainer.shap_values(instance)

            # Handle list structure (multi-class or binary lists)
            if isinstance(raw_shap, list):
                raw_shap = raw_shap[1] if len(raw_shap) > 1 else raw_shap[0]
            elif len(raw_shap.shape) == 3:
                raw_shap = raw_shap[:, :, 1]
                
            shap_flat = np.array(raw_shap).flatten()

            shap_vals_map = {
                col: float(val) 
                for col, val in zip(instance.columns, shap_flat)
            }

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
        else:
            # Native local feature attribution calculation
            base_value = 0.5
            cols = list(instance.columns)
            row_vals = instance.iloc[0].values
            
            # Baseline mean
            bg_means = self.background_data.mean().values if self.background_data is not None else np.zeros(len(cols))
            
            # Feature importances
            if hasattr(self.model, "feature_importances_"):
                importances = self.model.feature_importances_
            else:
                importances = np.ones(len(cols)) / len(cols)
                
            if np.sum(importances) > 0:
                importances = importances / np.sum(importances)
                
            # Local contribution = (value - baseline) * importance * sign(prediction)
            scale = 1.0 if prediction == 1 else -1.0
            deviations = row_vals - bg_means
            contributions = deviations * importances * scale * 2.0
            
            shap_vals_map = {col: float(c) for col, c in zip(cols, contributions)}
            
            return {
                "prediction": prediction,
                "confidence": confidence,
                "shap_values": shap_vals_map,
                "base_value": float(base_value),
                "raw_shap_matrix": contributions.reshape(1, -1)
            }
