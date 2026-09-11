import numpy as np
import pandas as pd
from app.core.logging import logger

class FeatureExtractor:
    def extract_features(self, df: pd.DataFrame) -> pd.DataFrame:
        if df.empty:
            return df
        
        df = df.copy()
        
        # Derived kinematic features
        df["speed_magnitude"] = np.sqrt(df["speed_x"]**2 + df["speed_y"]**2 + df["speed_z"]**2)
        df["pos_magnitude"] = np.sqrt(df["pos_x"]**2 + df["pos_y"]**2 + df["pos_z"]**2)
        
        # Position & Speed Deltas (grouped by vehicle_id)
        if "vehicle_id" in df.columns:
            df["delta_pos_x"] = df.groupby("vehicle_id")["pos_x"].diff().fillna(0.0)
            df["delta_pos_y"] = df.groupby("vehicle_id")["pos_y"].diff().fillna(0.0)
            df["delta_speed_x"] = df.groupby("vehicle_id")["speed_x"].diff().fillna(0.0)
            df["delta_speed_y"] = df.groupby("vehicle_id")["speed_y"].diff().fillna(0.0)
            df["time_diff"] = df.groupby("vehicle_id")["timestamp"].diff().fillna(0.1).replace(0, 0.1)
        else:
            df["delta_pos_x"] = df["pos_x"].diff().fillna(0.0)
            df["delta_pos_y"] = df["pos_y"].diff().fillna(0.0)
            df["delta_speed_x"] = df["speed_x"].diff().fillna(0.0)
            df["delta_speed_y"] = df["speed_y"].diff().fillna(0.0)
            df["time_diff"] = 0.1
            
        df["acceleration_x"] = df["delta_speed_x"] / df["time_diff"]
        df["acceleration_y"] = df["delta_speed_y"] / df["time_diff"]
        df["acceleration_magnitude"] = np.sqrt(df["acceleration_x"]**2 + df["acceleration_y"]**2)
        
        df["distance_from_center"] = np.sqrt((df["pos_x"] - 500)**2 + (df["pos_y"] - 500)**2)
        df["heading_angle"] = np.arctan2(df["speed_y"], df["speed_x"] + 1e-6)
        
        df["message_frequency"] = 1.0 / df["time_diff"]
        df["inter_arrival_time"] = df["time_diff"]
        
        logger.info(f"Feature engineering completed: generated 26 kinematic features.")
        return df
