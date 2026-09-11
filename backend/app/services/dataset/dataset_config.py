import os
from pathlib import Path

# Base directory mappings
SERVICES_DIR = Path(__file__).resolve().parent.parent
APP_DIR = SERVICES_DIR.parent
BACKEND_DIR = APP_DIR.parent
ROOT_DIR = BACKEND_DIR.parent

DATASET_DIR = ROOT_DIR / "dataset"
RAW_DATA_DIR = DATASET_DIR / "raw"
PROCESSED_DATA_DIR = DATASET_DIR / "processed"

# Ensure directories exist
os.makedirs(RAW_DATA_DIR, exist_ok=True)
os.makedirs(PROCESSED_DATA_DIR, exist_ok=True)

# Schema column definitions
FEATURE_COLUMNS = [
    "pos_x", "pos_y", "pos_z",
    "pos_noise_x", "pos_noise_y", "pos_noise_z",
    "speed_x", "speed_y", "speed_z",
    "speed_noise_x", "speed_noise_y", "speed_noise_z",
    "speed_magnitude", "pos_magnitude",
    "delta_pos_x", "delta_pos_y", "delta_speed_x", "delta_speed_y",
    "acceleration_x", "acceleration_y", "acceleration_magnitude",
    "distance_from_center", "heading_angle",
    "rssi", "message_frequency", "inter_arrival_time"
]

TARGET_COLUMN = "attacker_type"
BINARY_TARGET_COLUMN = "is_malicious"

# Train-Validation-Test Split Ratios
TRAIN_RATIO = 0.70
VAL_RATIO = 0.15
TEST_RATIO = 0.15
RANDOM_STATE = 42
