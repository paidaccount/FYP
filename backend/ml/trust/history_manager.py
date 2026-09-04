import os
import json
import numpy as np
from typing import Dict, Any, List
from app.core.logging import logger
from app.services.trust_config import TRUST_HISTORY_DIR

class VehicleHistoryManager:
    """
    Manages loading, updating, and saving vehicle behavior logs
    in JSON serialization format.
    """
    def __init__(self, history_dir=TRUST_HISTORY_DIR):
        self.history_dir = history_dir

    def _get_file_path(self, vehicle_id: str) -> str:
        return os.path.join(self.history_dir, f"{vehicle_id}.json")

    def load_history(self, vehicle_id: str) -> Dict[str, Any]:
        """Loads behavior history, returning a default dictionary if missing."""
        path = self._get_file_path(vehicle_id)
        if os.path.exists(path):
            try:
                with open(path, "r") as f:
                    return json.load(f)
            except Exception as e:
                logger.error(f"Failed to read history JSON for {vehicle_id}: {str(e)}")
        
        # Default behavior schema
        return {
            "vehicle_id": vehicle_id,
            "prediction_history": [],
            "attack_history": [],
            "trust_history": [],
            "message_history": [],
            "normal_run_duration": 0
        }

    def save_history(self, history: Dict[str, Any]) -> None:
        """Saves current vehicle behavioral state back to disk."""
        vehicle_id = history["vehicle_id"]
        path = self._get_file_path(vehicle_id)
        try:
            with open(path, "w") as f:
                json.dump(history, f, indent=4)
        except Exception as e:
            logger.error(f"Failed writing behavior history for {vehicle_id}: {str(e)}")

    def record_event(
        self, 
        vehicle_id: str, 
        prediction: int, 
        attack_type: str, 
        trust_score: float, 
        message_features: Dict[str, Any]
    ) -> Dict[str, Any]:
        """
        Appends a new epoch telemetry record to the history log,
        calculating continuous normal behavior durations.
        """
        history = self.load_history(vehicle_id)

        history["prediction_history"].append(prediction)
        history["attack_history"].append(attack_type)
        history["trust_history"].append(trust_score)
        
        # Clean dictionary before saving to prevent NumPy data type serialization errors
        clean_features = {k: float(v) if isinstance(v, (np.float32, np.float64)) else v for k, v in message_features.items()}
        history["message_history"].append(clean_features)

        # Update normal run counter
        if prediction == 0:
            history["normal_run_duration"] += 1
        else:
            history["normal_run_duration"] = 0 # Reset normal duration if malicious action detected

        self.save_history(history)
        return history
