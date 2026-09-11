import os
from pathlib import Path
from typing import List
from app.services.dataset.dataset_config import RAW_DATA_DIR
from app.core.logging import logger

class DatasetDownloader:
    def __init__(self, raw_dir: str = None):
        self.raw_dir = Path(raw_dir) if raw_dir else RAW_DATA_DIR

    def check_datasets(self) -> None:
        self.raw_dir.mkdir(parents=True, exist_ok=True)
        count = len(list(self.raw_dir.glob("*.json")))
        logger.info(f"Checking dataset directory '{self.raw_dir}': found {count} JSON trace files.")

    def verify_local_files(self) -> bool:
        json_files = list(self.raw_dir.glob("*.json"))
        return len(json_files) > 0
