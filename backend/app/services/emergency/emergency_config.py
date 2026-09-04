import os
from pathlib import Path

# Paths
EMERGENCY_DIR = Path(__file__).resolve().parent
ML_DIR = EMERGENCY_DIR.parent
BACKEND_DIR = ML_DIR.parent.parent
REPORTS_DIR = BACKEND_DIR / "reports"
EMERGENCY_PLOTS_DIR = REPORTS_DIR / "emergency"

# Ensure plot directories exist
os.makedirs(EMERGENCY_PLOTS_DIR, exist_ok=True)

# Authentication Parameters
AUTH_TOKEN_PREFIX = "AUTH_EMERGENCY_"

# Priority Weight Coefficients
WEIGHT_VEHICLE_TYPE = 0.40
WEIGHT_TRUST_SCORE = 0.30
WEIGHT_ACCIDENT_SEVERITY = 0.20
WEIGHT_TRAFFIC_CONDITIONS = 0.10

# Verification of weights sum up to 1.0
assert abs((WEIGHT_VEHICLE_TYPE + WEIGHT_TRUST_SCORE + WEIGHT_ACCIDENT_SEVERITY + WEIGHT_TRAFFIC_CONDITIONS) - 1.0) < 1e-6, "Weights must sum to 1.0"

# Speed assumptions (m/s) per vehicle type
VEHICLE_SPEEDS = {
    "Ambulance": 25.0,
    "Fire Brigade": 22.0,
    "Police": 27.0,
    "Rescue": 20.0,
    "Standard": 15.0
}
