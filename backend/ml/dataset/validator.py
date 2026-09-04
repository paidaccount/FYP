import json
import numpy as np
import pandas as pd
from app.core.logging import logger

class DatasetValidator:
    def validate_df(self, df: pd.DataFrame) -> dict:
        logger.info("Validating dataframe features and integrity...")
        
        total_records = len(df)
        missing_vals = int(df.isnull().sum().sum())
        inf_vals = int(np.isinf(df.select_dtypes(include=np.number)).sum().sum())
        
        label_dist = {str(k): int(v) for k, v in df["attack_label"].value_counts().to_dict().items()}
        binary_dist = {str(k): int(v) for k, v in df["is_malicious"].value_counts().to_dict().items()}
        
        feature_ranges = {}
        for col in df.columns:
            if pd.api.types.is_numeric_dtype(df[col]):
                feature_ranges[col] = {
                    "min": float(df[col].min()),
                    "max": float(df[col].max()),
                    "mean": float(df[col].mean())
                }
                
        missing_per_column = {col: int(df[col].isnull().sum()) for col in df.columns}
        
        status = "PASSED" if missing_vals == 0 and inf_vals == 0 else "FAILED"
        
        return {
            "status": status,
            "total_records": total_records,
            "missing_values_sum": missing_vals,
            "infinite_values_sum": inf_vals,
            "label_distribution": label_dist,
            "binary_distribution": binary_dist,
            "feature_ranges": feature_ranges,
            "missing_per_column": missing_per_column
        }

    def save_report(self, report: dict, file_path: str) -> None:
        logger.info(f"Saving validation report to {file_path}")
        with open(file_path, "w") as f:
            json.dump(report, f, indent=4)
