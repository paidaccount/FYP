import json
import pandas as pd
from typing import Dict, Any
from app.core.logging import logger

class DatasetValidator:
    def validate_df(self, df: pd.DataFrame) -> Dict[str, Any]:
        return self.validate_processed_data(df, [c for c in df.columns if c not in ["vehicle_id", "timestamp"]])

    def validate_processed_data(self, df: pd.DataFrame, feature_cols: list) -> Dict[str, Any]:
        report = {
            "total_records": int(len(df)),
            "feature_count": int(len(feature_cols)),
            "missing_values": int(df[feature_cols].isnull().sum().sum()) if feature_cols else 0,
            "infinite_values": int(df[feature_cols].isin([float("inf"), float("-inf")]).sum().sum()) if feature_cols else 0,
            "class_distribution": df["is_malicious"].value_counts().to_dict() if "is_malicious" in df.columns else {}
        }
        logger.info(f"Dataset validation report: {report}")
        return report

    def save_report(self, report: Dict[str, Any], filepath: str) -> None:
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(report, f, indent=4)
