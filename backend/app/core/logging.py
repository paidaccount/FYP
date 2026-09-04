import logging
import sys
from typing import Any

# Configure log output format
LOG_FORMAT = "%(asctime)s - %(levelname)s - %(name)s - [%(filename)s:%(lineno)d] - %(message)s"

def setup_logging() -> None:
    """
    Initializes central logging configuration, setting level thresholds and output streams.
    """
    logging.basicConfig(
        level=logging.INFO,
        format=LOG_FORMAT,
        handlers=[
            logging.StreamHandler(sys.stdout)
        ]
    )

    # Set external libraries log levels to prevent clutter
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("sqlalchemy.engine").setLevel(logging.WARNING)

# Export standard system loggers
logger = logging.getLogger("vanet_system")
auth_logger = logging.getLogger("vanet_auth")
db_logger = logging.getLogger("vanet_database")
ml_logger = logging.getLogger("vanet_ml")
trust_logger = logging.getLogger("vanet_trust")
emergency_logger = logging.getLogger("vanet_emergency")
route_logger = logging.getLogger("vanet_route")
