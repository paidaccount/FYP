import json
import pandas as pd
from pathlib import Path
from app.services.dataset.dataset_config import RAW_DATA_DIR
from app.services.dataset.attack_mapping import map_raw_attacker_type, is_malicious
from app.core.logging import logger

class DatasetLoader:
    def __init__(self, raw_dir: str = None):
        self.raw_dir = Path(raw_dir) if raw_dir else RAW_DATA_DIR

    def load_all_traces(self) -> pd.DataFrame:
        records = []
        json_files = sorted(list(self.raw_dir.glob("*.json")))
        logger.info(f"Loading telemetry traces from {len(json_files)} trace files in {self.raw_dir}...")

        for file_path in json_files:
            try:
                items = []
                with open(file_path, "r", encoding="utf-8") as f:
                    content = f.read().strip()
                    if content.startswith("["):
                        items = json.loads(content)
                    else:
                        for line in content.splitlines():
                            line = line.strip()
                            if line:
                                try:
                                    items.append(json.loads(line))
                                except json.JSONDecodeError:
                                    pass
                for entry in items:
                    pos = entry.get("pos", [0.0, 0.0, 0.0])
                    pos_noise = entry.get("pos_noise", [0.0, 0.0, 0.0])
                    speed = entry.get("spd", entry.get("speed", [0.0, 0.0, 0.0]))
                    speed_noise = entry.get("spd_noise", entry.get("speed_noise", [0.0, 0.0, 0.0]))
                    
                    attacker_type = map_raw_attacker_type(entry.get("attacker_type", entry.get("type", 0)))
                    
                    record = {
                        "vehicle_id": str(entry.get("sender", entry.get("vehicle_id", "UNKNOWN"))),
                        "timestamp": float(entry.get("rcvTime", entry.get("sendTime", entry.get("timestamp", 0.0)))),
                        "pos_x": float(pos[0]) if len(pos) > 0 else 0.0,
                        "pos_y": float(pos[1]) if len(pos) > 1 else 0.0,
                        "pos_z": float(pos[2]) if len(pos) > 2 else 0.0,
                        "pos_noise_x": float(pos_noise[0]) if len(pos_noise) > 0 else 0.0,
                        "pos_noise_y": float(pos_noise[1]) if len(pos_noise) > 1 else 0.0,
                        "pos_noise_z": float(pos_noise[2]) if len(pos_noise) > 2 else 0.0,
                        "speed_x": float(speed[0]) if len(speed) > 0 else 0.0,
                        "speed_y": float(speed[1]) if len(speed) > 1 else 0.0,
                        "speed_z": float(speed[2]) if len(speed) > 2 else 0.0,
                        "speed_noise_x": float(speed_noise[0]) if len(speed_noise) > 0 else 0.0,
                        "speed_noise_y": float(speed_noise[1]) if len(speed_noise) > 1 else 0.0,
                        "speed_noise_z": float(speed_noise[2]) if len(speed_noise) > 2 else 0.0,
                        "rssi": float(entry.get("rssi", -65.0)),
                        "attacker_type": attacker_type,
                        "is_malicious": is_malicious(attacker_type)
                    }
                    records.append(record)
            except Exception as e:
                logger.warning(f"Failed to parse trace file {file_path.name}: {e}")

        df = pd.DataFrame(records)
        logger.info(f"Loaded {len(df)} total telemetry records.")
        return df
