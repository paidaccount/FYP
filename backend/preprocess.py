import os
import json
import joblib
import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler

from app.core.logging import logger, setup_logging
from ml.dataset.dataset_config import (
    PROCESSED_DATA_DIR,
    FEATURE_COLUMNS,
    TARGET_COLUMN,
    BINARY_TARGET_COLUMN
)
from ml.dataset.downloader import DatasetDownloader
from ml.dataset.loader import DatasetLoader
from ml.dataset.preprocessing import DatasetPreprocessor
from ml.dataset.feature_engineering import FeatureExtractor
from ml.dataset.attack_mapping import map_raw_attacker_type, is_malicious, ATTACK_LABELS
from ml.dataset.validator import DatasetValidator

# Configure logging
setup_logging()

def run_pipeline() -> None:
    logger.info("Initializing VANET Dataset Preprocessing Pipeline (Kaggle Ingestion Mode)...")

    # 1. Verify presence of raw datasets in Kaggle input directories
    downloader = DatasetDownloader()
    downloader.check_datasets()
    if not downloader.verify_local_files():
        logger.error("Required raw dataset trace files are missing. Pipeline execution aborted.")
        raise FileNotFoundError("Raw VeReMi/Extension dataset traces not found in configured paths.")

    # 2. Load raw files recursively
    loader = DatasetLoader()
    raw_df = loader.load_all_traces()
    if raw_df.empty:
        logger.error("Data loading returned empty DataFrame. Halting pipeline.")
        return

    # 3. Clean telemetry
    preprocessor = DatasetPreprocessor()
    cleaned_df = preprocessor.clean_telemetry(raw_df)
    if cleaned_df.empty:
        logger.error("Cleaning resulted in empty DataFrame. Halting pipeline.")
        return

    # 4. Feature Extraction & Engineering
    extractor = FeatureExtractor()
    featured_df = extractor.extract_features(cleaned_df)
    if featured_df.empty:
        logger.error("Feature extraction returned empty DataFrame. Halting.")
        return

    # 5. Attack Label Mapping
    logger.info("Mapping attack types and binary classification targets...")
    featured_df[TARGET_COLUMN] = featured_df["attackerType"].apply(map_raw_attacker_type)
    featured_df[BINARY_TARGET_COLUMN] = featured_df[TARGET_COLUMN].apply(is_malicious)

    # 6. Stratified Split (Train 70%, Val 15%, Test 15%)
    logger.info("Splitting dataset into stratified Train/Validation/Test sets...")
    
    # Stratify split requires at least one instance per class. For safety, 
    # if any class has count < 2, we default to standard split to prevent ValueError.
    class_counts = featured_df[TARGET_COLUMN].value_counts()
    stratify_col = featured_df[TARGET_COLUMN] if class_counts.min() >= 2 else None

    # First split: Train (70%) and Temp (30%)
    train_df, temp_df = train_test_split(
        featured_df,
        test_size=0.30,
        random_state=42,
        stratify=stratify_col
    )

    # Second split: Val (15%) and Test (15%)
    temp_stratify = temp_df[TARGET_COLUMN] if stratify_col is not None else None
    val_df, test_df = train_test_split(
        temp_df,
        test_size=0.50,
        random_state=42,
        stratify=temp_stratify
    )

    # 7. Normalize Features (Fit on TRAIN ONLY to avoid data leakage)
    logger.info("Fitting and applying StandardScaler on feature columns...")
    scaler = StandardScaler()
    scaler.fit(train_df[FEATURE_COLUMNS])

    # Transform splits
    train_df[FEATURE_COLUMNS] = scaler.transform(train_df[FEATURE_COLUMNS])
    val_df[FEATURE_COLUMNS] = scaler.transform(val_df[FEATURE_COLUMNS])
    test_df[FEATURE_COLUMNS] = scaler.transform(test_df[FEATURE_COLUMNS])

    # 8. Save Processed Outputs
    logger.info(f"Saving outputs to '{PROCESSED_DATA_DIR}'...")
    
    train_df.to_csv(PROCESSED_DATA_DIR / "train.csv", index=False)
    val_df.to_csv(PROCESSED_DATA_DIR / "validation.csv", index=False)
    test_df.to_csv(PROCESSED_DATA_DIR / "test.csv", index=False)

    # Save Scaler binary
    joblib.dump(scaler, PROCESSED_DATA_DIR / "scaler.pkl")

    # Save feature names list
    with open(PROCESSED_DATA_DIR / "feature_names.json", "w") as f:
        json.dump(FEATURE_COLUMNS, f, indent=4)

    # Save label mappings dictionary
    with open(PROCESSED_DATA_DIR / "label_mapping.json", "w") as f:
        json.dump(ATTACK_LABELS, f, indent=4)

    # 9. Run Validation & Generate Report
    logger.info("Validating clean dataset sets...")
    validator = DatasetValidator()
    report = validator.validate_df(featured_df)
    validator.save_report(report, str(PROCESSED_DATA_DIR / "validation_report.json"))

    # 10. Generate Visualizations (Matplotlib / JSON stats)
    generate_statistics_and_plots(featured_df)

    logger.info("Dataset Preparation and Data Processing Pipeline Completed Successfully!")

def generate_statistics_and_plots(df: pd.DataFrame) -> None:
    """
    Computes analytics and exports visualizations. Uses JSON stubs if matplotlib 
    is not installed in local workspace runner environment.
    """
    logger.info("Generating dataset distribution statistics...")
    
    stats = {
        "num_vehicles": int(df["vehicle_id"].nunique()),
        "num_messages": int(len(df)),
        "attack_distribution": {
            ATTACK_LABELS[k]: int(v) 
            for k, v in df[TARGET_COLUMN].value_counts().to_dict().items()
        },
        "normal_vs_malicious_ratio": {
            "Normal": int((df[BINARY_TARGET_COLUMN] == 0).sum()),
            "Malicious": int((df[BINARY_TARGET_COLUMN] == 1).sum())
        },
        "speed_stats": {
            "min": float(df["speed"].min()),
            "max": float(df["speed"].max()),
            "mean": float(df["speed"].mean())
        }
    }
    
    stats_out = PROCESSED_DATA_DIR / "dataset_statistics.json"
    with open(stats_out, "w") as f:
        json.dump(stats, f, indent=4)
    logger.info(f"Analytics exported successfully to: {stats_out}")

    # Plot saves (Matplotlib safe wrapper)
    try:
        import matplotlib.pyplot as plt
        logger.info("Matplotlib detected. Generating distribution charts...")
        
        plot_dir = PROCESSED_DATA_DIR / "plots"
        os.makedirs(plot_dir, exist_ok=True)
        
        # 1. Attack distribution chart
        plt.figure(figsize=(10, 5))
        df[TARGET_COLUMN].map(ATTACK_LABELS).value_counts().plot(kind="bar", color="purple")
        plt.title("Attack Class Distribution")
        plt.xlabel("Attack Class")
        plt.ylabel("Number of Messages")
        plt.tight_layout()
        plt.savefig(plot_dir / "attack_distribution.png")
        plt.close()

        # 2. Speed distribution chart
        plt.figure(figsize=(8, 4))
        df["speed"].plot(kind="hist", bins=30, color="teal")
        plt.title("Vehicle Speed Distribution")
        plt.xlabel("Speed (m/s)")
        plt.ylabel("Frequency")
        plt.tight_layout()
        plt.savefig(plot_dir / "speed_distribution.png")
        plt.close()
        
        logger.info(f"Visualization plots saved to: {plot_dir}")
        
    except ImportError:
        logger.warning("Matplotlib is not installed. Skipping plot chart image generation.")

if __name__ == "__main__":
    run_pipeline()
