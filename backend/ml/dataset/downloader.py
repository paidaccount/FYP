import os
import glob
from pathlib import Path
from app.core.logging import logger
from ml.dataset.dataset_config import RAW_DATA_DIR

class DatasetDownloader:
    def __init__(self, raw_dir: str = None):
        self.raw_dir = Path(raw_dir) if raw_dir else RAW_DATA_DIR

    def check_datasets(self) -> None:
        logger.info(f"Checking for raw dataset files in {self.raw_dir}...")
        if self.verify_local_files():
            logger.info("Raw datasets found locally.")
        else:
            logger.warning("No raw dataset files found locally.")

    def verify_local_files(self) -> bool:
        if not os.path.exists(self.raw_dir):
            return False
        json_files = glob.glob(os.path.join(self.raw_dir, "*.json"))
        return len(json_files) > 0
