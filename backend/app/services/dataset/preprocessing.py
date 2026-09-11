import numpy as np
import pandas as pd
from app.core.logging import logger

class DatasetPreprocessor:
    def clean_telemetry(self, df: pd.DataFrame) -> pd.DataFrame:
        if df.empty:
            return df
        initial_len = len(df)
        
        # Deduplicate
        df = df.drop_duplicates().copy()
        
        # Sort by vehicle and timestamp
        if "vehicle_id" in df.columns and "timestamp" in df.columns:
            df = df.sort_values(by=["vehicle_id", "timestamp"]).reset_index(drop=True)
            
        # Fill missing values
        numeric_cols = df.select_dtypes(include=[np.number]).columns
        df[numeric_cols] = df[numeric_cols].fillna(0.0)
        
        logger.info(f"Cleaned telemetry: {initial_len} -> {len(df)} records.")
        return df
