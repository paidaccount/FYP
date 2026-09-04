import os
import glob
import json
from pathlib import Path
import pandas as pd
from app.core.logging import logger
from ml.dataset.dataset_config import RAW_DATA_DIR

class DatasetLoader:
    def __init__(self, raw_dir: str = None):
        self.raw_dir = Path(raw_dir) if raw_dir else RAW_DATA_DIR

    def load_all_traces(self) -> pd.DataFrame:
        logger.info(f"Loading raw traces from {self.raw_dir}...")
        if not os.path.exists(self.raw_dir):
            logger.warning(f"Raw directory {self.raw_dir} does not exist.")
            return pd.DataFrame()
            
        json_files = glob.glob(os.path.join(self.raw_dir, "*.json"))
        if not json_files:
            logger.warning(f"No JSON trace files found in {self.raw_dir}")
            return pd.DataFrame()
            
        all_records = []
        for file_path in json_files:
            try:
                with open(file_path, "r") as f:
                    for line in f:
                        line = line.strip()
                        if line:
                            all_records.append(json.loads(line))
            except Exception as e:
                logger.error(f"Error reading file {file_path}: {e}")
                
        if not all_records:
            return pd.DataFrame()
            
        df = pd.DataFrame(all_records)
        logger.info(f"Loaded {len(df)} raw message records from {len(json_files)} trace files.")
        return df
