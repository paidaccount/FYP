import os
from pathlib import Path

# Paths
ROUTING_DIR = Path(__file__).resolve().parent
SERVICES_DIR = ROUTING_DIR.parent
APP_DIR = SERVICES_DIR.parent
BACKEND_DIR = APP_DIR.parent
REPORTS_DIR = BACKEND_DIR / "reports"
ROUTING_PLOTS_DIR = REPORTS_DIR / "routes"

# Ensure plot directories exist
os.makedirs(ROUTING_PLOTS_DIR, exist_ok=True)

# Node 2D Grid coordinates mapping for A* heuristics distance evaluation
NODE_COORDINATES = {
    "A": (0.0, 0.0),
    "B": (3.0, 4.0),
    "C": (6.0, 0.0),
    "D": (3.0, -4.0),
    "E": (9.0, 4.0),
    "F": (12.0, 0.0)
}

# Dynamic Route Cost Formula weights (Must sum to 1.0)
WEIGHT_DISTANCE = 0.40
WEIGHT_CONGESTION = 0.40
WEIGHT_ACCIDENT_RISK = 0.20

assert abs((WEIGHT_DISTANCE + WEIGHT_CONGESTION + WEIGHT_ACCIDENT_RISK) - 1.0) < 1e-6, "Weights must sum to 1.0"
