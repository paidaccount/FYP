import os
import matplotlib
matplotlib.use("Agg") # Prevent Tkinter GUI errors on headless servers
import matplotlib.pyplot as plt
import numpy as np
import shap
from typing import Dict, Any, List
from app.core.logging import logger
from app.services.xai.config import REPORTS_DIR

SHAP_REPORTS_DIR = REPORTS_DIR / "xai" / "shap"
LIME_REPORTS_DIR = REPORTS_DIR / "xai" / "lime"

os.makedirs(SHAP_REPORTS_DIR, exist_ok=True)
os.makedirs(LIME_REPORTS_DIR, exist_ok=True)

class XAIVisualizer:
    """
    Renders and exports graphical local and global explanations:
    - SHAP summary, bar, waterfall, and force plots
    - LIME pyplot features weight contribution charts
    """
    def save_shap_plots(
        self, 
        prediction_id: str, 
        shap_values: Dict[str, float], 
        base_value: float, 
        instance_data: Dict[str, float]
    ) -> None:
        try:
            logger.info(f"Generating SHAP plots for prediction ID: {prediction_id}")
            feature_names = list(shap_values.keys())
            contribs = np.array(list(shap_values.values()))
            raw_vals = np.array(list(instance_data.values()))

            # Construct an Explanation container required by newer SHAP plot functions
            exp_obj = shap.Explanation(
                values=contribs,
                base_values=base_value,
                data=raw_vals,
                feature_names=feature_names
            )

            # 1. Bar Plot
            plt.figure(figsize=(8, 4))
            shap.plots.bar(exp_obj, show=False)
            plt.tight_layout()
            plt.savefig(SHAP_REPORTS_DIR / f"{prediction_id}_bar.png")
            plt.close()

            # 2. Waterfall Plot
            plt.figure(figsize=(8, 5))
            shap.plots.waterfall(exp_obj, show=False)
            plt.tight_layout()
            plt.savefig(SHAP_REPORTS_DIR / f"{prediction_id}_waterfall.png")
            plt.close()

            # 3. Force Plot
            plt.figure(figsize=(10, 3))
            shap.force_plot(
                base_value, 
                contribs, 
                raw_vals, 
                feature_names=feature_names, 
                matplotlib=True, 
                show=False
            )
            plt.tight_layout()
            plt.savefig(SHAP_REPORTS_DIR / f"{prediction_id}_force.png")
            plt.close()

        except Exception as e:
            logger.error(f"Failed rendering local SHAP plots: {str(e)}", exc_info=True)

    def save_global_shap_summary(self, explainer_model: Any, test_data: np.ndarray, feature_names: List[str]) -> None:
        """
        Generates and saves the overall global feature importance Summary Plot.
        """
        try:
            logger.info("Generating global SHAP summary plot...")
            plt.figure(figsize=(10, 6))
            
            # Simple wrapper to check TreeExplainer vs Kernel
            if hasattr(explainer_model, "shap_values"):
                # Compute SHAP values for test data matrix
                shap_vals = explainer_model.shap_values(test_data)
                
                # Retrieve positive class contributions if binary list
                if isinstance(shap_vals, list):
                    shap_vals = shap_vals[1] if len(shap_vals) > 1 else shap_vals[0]
                elif len(shap_vals.shape) == 3:
                    shap_vals = shap_vals[:, :, 1]
                
                shap.summary_plot(shap_vals, test_data, feature_names=feature_names, show=False)
                plt.tight_layout()
                plt.savefig(SHAP_REPORTS_DIR / "global_summary.png")
                plt.close()
                logger.info("Global summary plot exported successfully.")
        except Exception as e:
            logger.error(f"Failed rendering global SHAP summary: {str(e)}")

    def save_lime_plots(self, prediction_id: str, lime_explanation_obj: Any) -> None:
        """
        Generates and exports LIME local explanation bar graphs.
        """
        try:
            logger.info(f"Generating LIME plots for prediction ID: {prediction_id}")
            fig = lime_explanation_obj.as_pyplot_figure()
            plt.title("LIME Local Feature Contribution", fontsize=12)
            plt.tight_layout()
            plt.savefig(LIME_REPORTS_DIR / f"{prediction_id}_lime.png")
            plt.close()
        except Exception as e:
            logger.error(f"Failed exporting LIME charts: {str(e)}")
