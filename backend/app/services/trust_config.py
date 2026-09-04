import os
from pathlib import Path

# Paths
TRUST_DIR = Path(__file__).resolve().parent
ML_DIR = TRUST_DIR.parent
BACKEND_DIR = ML_DIR.parent.parent
REPORTS_DIR = BACKEND_DIR / "reports"
TRUST_HISTORY_DIR = BACKEND_DIR / "trust_history"
TRUST_PLOTS_DIR = REPORTS_DIR / "trust"

# Ensure directories exist
os.makedirs(TRUST_HISTORY_DIR, exist_ok=True)
os.makedirs(TRUST_PLOTS_DIR, exist_ok=True)

# Trust Limits
INITIAL_TRUST = 100.0
TRUST_MIN = 0.0
TRUST_MAX = 100.0

# Trust Categories
TRUSTED_THRESHOLD = 80.0
SUSPICIOUS_THRESHOLD = 40.0

# Formula Weights
WEIGHT_DIRECT = 0.40
WEIGHT_HISTORY = 0.30
WEIGHT_COMMUNICATION = 0.20
WEIGHT_XAI = 0.10

# Verification of weights sum up to 1.0
assert abs((WEIGHT_DIRECT + WEIGHT_HISTORY + WEIGHT_COMMUNICATION + WEIGHT_XAI) - 1.0) < 1e-6, "Weights must sum to 1.0"
