import os
from pathlib import Path

# Base directory mappings
XAI_DIR = Path(__file__).resolve().parent
ML_DIR = XAI_DIR.parent
BACKEND_DIR = ML_DIR.parent.parent
DATA_DIR = BACKEND_DIR / "data"
PROCESSED_DATA_DIR = DATA_DIR / "processed"

# XAI exports targets
XAI_PLOTS_DIR = PROCESSED_DATA_DIR / "plots" / "xai"
SHAP_PLOTS_DIR = XAI_PLOTS_DIR / "shap"
LIME_PLOTS_DIR = XAI_PLOTS_DIR / "lime"
SAVED_EXPLANATIONS_DIR = PROCESSED_DATA_DIR / "explanations"
REPORTS_DIR = BACKEND_DIR / "reports"

# Model paths
MODEL_PATH = DATA_DIR / "models" / "best_model.joblib"

# Ensure directories exist
os.makedirs(SHAP_PLOTS_DIR, exist_ok=True)
os.makedirs(LIME_PLOTS_DIR, exist_ok=True)
os.makedirs(SAVED_EXPLANATIONS_DIR, exist_ok=True)
os.makedirs(REPORTS_DIR, exist_ok=True)
os.makedirs(MODEL_PATH.parent, exist_ok=True)

# Feature importance filtering configurations
FEATURE_IMPORTANCE_LIMIT = 5
LIME_MIN_WEIGHT_THRESHOLD = 0.05
