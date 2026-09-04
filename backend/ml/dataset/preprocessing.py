import pandas as pd
import numpy as np
from app.core.logging import logger

class DatasetPreprocessor:
    def clean_telemetry(self, df: pd.DataFrame) -> pd.DataFrame:
        if df.empty:
            return df
        
        logger.info("Cleaning raw telemetry data...")
        df = df.dropna(subset=["pos", "spd"]).copy()
        
        # Expand 'pos' list into position_x, position_y, position_z
        pos_arr = np.array(df["pos"].tolist())
        df["position_x"] = pos_arr[:, 0]
        df["position_y"] = pos_arr[:, 1]
        df["position_z"] = pos_arr[:, 2]
        
        # Expand 'spd' list into speed_x, speed_y, speed_z
        spd_arr = np.array(df["spd"].tolist())
        df["speed_x"] = spd_arr[:, 0]
        df["speed_y"] = spd_arr[:, 1]
        df["speed_z"] = spd_arr[:, 2]
        
        # Ensure correct type format
        df["t"] = df["t"].astype(float)
        df["sender"] = df["sender"].astype(int)
        df["messageID"] = df["messageID"].astype(int)
        df["attackerType"] = df["attackerType"].astype(int)
        
        # Drop raw 'pos' and 'spd' columns to fit expected features schema
        df = df.drop(columns=["pos", "spd"])
        
        logger.info(f"Telemetry cleaning complete. Remaining records: {len(df)}")
        return df
