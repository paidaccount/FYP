import os
from pathlib import Path

# Paths
DATASET_DIR = Path(__file__).resolve().parent
ML_DIR = DATASET_DIR.parent
BACKEND_DIR = ML_DIR.parent
DATA_DIR = BACKEND_DIR / "data"
RAW_DATA_DIR = DATA_DIR / "raw"
PROCESSED_DATA_DIR = DATA_DIR / "processed"

# Feature definitions
FEATURE_COLUMNS = [
    "vehicle_id",
    "timestamp",
    "position_x",
    "position_y",
    "speed",
    "acceleration",
    "direction",
    "heading",
    "lane_position",
    "message_frequency",
    "message_interval",
    "neighbor_count",
    "communication_rate",
    "packet_count",
    "speed_change_rate",
    "position_change_rate",
    "distance_difference",
    "trajectory_consistency",
    "message_consistency",
    "GPS_consistency",
    "speed_anomaly_score",
    "position_anomaly_score",
    "message_frequency_anomaly",
    "acceleration_anomaly",
    "trajectory_deviation",
    "communication_behavior_score"
]

TARGET_COLUMN = "attack_label"
BINARY_TARGET_COLUMN = "is_malicious"
