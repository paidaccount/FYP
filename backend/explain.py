import os
import json
import joblib
import pandas as pd
import numpy as np
from xgboost import XGBClassifier

from app.core.logging import logger, setup_logging
from ml.dataset.dataset_config import (
    PROCESSED_DATA_DIR,
    FEATURE_COLUMNS,
    TARGET_COLUMN,
    BINARY_TARGET_COLUMN
)
from app.services.xai.config import MODEL_PATH, SAVED_EXPLANATIONS_DIR
from app.services.xai.xai_pipeline import XAIPipeline
from app.services.xai.visualization import XAIVisualizer

# Configure logging
setup_logging()

def train_helper() -> XGBClassifier:
    """
    Trains a standard XGBoost classifier on the preprocessed training dataset
    to establish the model binary for explanation queries.
    """
    train_path = PROCESSED_DATA_DIR / "train.csv"
    if not os.path.exists(train_path):
        raise FileNotFoundError(f"Training dataset '{train_path}' is missing. Run 'preprocess.py' first.")

    logger.info("Loading preprocessed training data...")
    train_df = pd.read_csv(train_path)
    
    X_train = train_df[FEATURE_COLUMNS]
    y_train = train_df[BINARY_TARGET_COLUMN]

    logger.info(f"Training XGBoost classifier on {len(X_train)} records...")
    model = XGBClassifier(
        n_estimators=30,
        max_depth=4,
        random_state=42,
        eval_metric="logloss"
    )
    model.fit(X_train, y_train)

    logger.info(f"Saving trained model binary to: {MODEL_PATH}")
    joblib.dump(model, MODEL_PATH)
    return model

def run_xai_pipeline() -> None:
    logger.info("Starting Explainable AI Pipeline...")

    # 1. Load or train model
    if not os.path.exists(MODEL_PATH):
        logger.warning(f"No pre-trained model found at '{MODEL_PATH}'. Training one now...")
        model = train_helper()
    else:
        logger.info(f"Loading pre-trained model binary from: {MODEL_PATH}")
        model = joblib.load(MODEL_PATH)

    # 2. Load test set background data
    test_path = PROCESSED_DATA_DIR / "test.csv"
    if not os.path.exists(test_path):
        raise FileNotFoundError(f"Test dataset '{test_path}' is missing. Run 'preprocess.py' first.")
        
    test_df = pd.read_csv(test_path)
    X_test = test_df[FEATURE_COLUMNS]

    # Initialize visualizer and pipeline
    visualizer = XAIVisualizer()
    pipeline = XAIPipeline(model, X_test, visualizer=visualizer)

    # 3. Simulate and evaluate the 4 required Test Cases
    # We will pick a base normal vehicle row and modify its features to simulate attacks
    normal_rows = test_df[test_df[BINARY_TARGET_COLUMN] == 0]
    if normal_rows.empty:
        normal_rows = test_df
    
    base_row = normal_rows.iloc[0:1].copy()

    # Define Test Cases list
    test_cases = []

    # Case 1: Normal Vehicle
    case_normal = base_row.copy()
    # Reset any anomalous features
    for col in FEATURE_COLUMNS:
        if "anomaly" in col or "consistency" in col or "deviation" in col:
            case_normal[col] = 0.0
    test_cases.append((case_normal, "VEHICLE_NORMAL", "Normal vehicle"))

    # Case 2: False Position Attack
    # Inject spatial coordinates discrepancies
    case_false_pos = base_row.copy()
    case_false_pos["position_anomaly_score"] = 5.5
    case_false_pos["GPS_consistency"] = 4.2
    test_cases.append((case_false_pos, "VEHICLE_ATTACK_POSITION", "False Position Attack"))

    # Case 3: False Speed Attack
    # Inject speed and acceleration fluctuations
    case_false_speed = base_row.copy()
    case_false_speed["speed_anomaly_score"] = 6.2
    case_false_speed["acceleration_anomaly"] = 1.0
    case_false_speed["speed_change_rate"] = 5.0
    test_cases.append((case_false_speed, "VEHICLE_ATTACK_SPEED", "False Speed Attack"))

    # Case 4: Fake Emergency Message Spoofing
    # Inject high messaging density and frequency anomalies
    case_fake_emergency = base_row.copy()
    case_fake_emergency["message_frequency_anomaly"] = 1.0
    case_fake_emergency["message_frequency"] = 12.0
    case_fake_emergency["communication_behavior_score"] = 10.0
    test_cases.append((case_fake_emergency, "VEHICLE_ATTACK_EMERGENCY", "Fake Emergency Message"))

    # 4. Generate Explanations for all Cases
    logger.info("Executing local explanations and saving records...")
    explanation_records = []

    for df_row, vehicle_id, label in test_cases:
        # Run pipeline prediction and explanations
        instance_features = df_row[FEATURE_COLUMNS]
        record = pipeline.explain_instance(instance_features, vehicle_id)
        
        explanation_records.append(record)

        # Print human-readable output to console
        print("\n==================================================")
        print(f"TEST CASE: {label} (ID: {vehicle_id})")
        print(f"Prediction: {record['prediction']}")
        print(f"Confidence: {record['confidence']*100:.1f}%")
        print(f"Explanation: {record['generated_reason']}")
        print("==================================================")

        # Save JSON output record
        out_file = SAVED_EXPLANATIONS_DIR / f"{vehicle_id}_explanation.json"
        with open(out_file, "w") as f:
            json.dump(record, f, indent=4)
        logger.info(f"JSON explanation exported to: {out_file}")

    # 5. Generate Global SHAP Summary Plot
    visualizer.save_global_shap_summary(pipeline.shap_wrapper.explainer, np.array(X_test), FEATURE_COLUMNS)

    logger.info("XAI Pipeline Run Completed Successfully!")

if __name__ == "__main__":
    run_xai_pipeline()
