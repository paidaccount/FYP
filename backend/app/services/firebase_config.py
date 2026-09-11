import importlib
from app.core.logging import logger

try:
    firebase_admin = importlib.import_module("firebase_admin")
    credentials = importlib.import_module("firebase_admin.credentials")
    FIREBASE_AVAILABLE = True
except ImportError:
    firebase_admin = None
    credentials = None
    FIREBASE_AVAILABLE = False

# Global flag indicating if Firebase Admin is fully initialized
firebase_initialized = False

def initialize_firebase() -> bool:
    """
    Initializes Firebase Admin SDK using service account keys.
    Falls back gracefully if credentials are not configured or package is not installed.
    """
    global firebase_initialized
    if firebase_initialized:
        return True

    if not FIREBASE_AVAILABLE:
        logger.info("firebase_admin package not installed. Operating in mock / simulation notification mode.")
        firebase_initialized = False
        return False

    # Try loading service account path from environment variables
    cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-service-account.json")
    
    try:
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            firebase_initialized = True
            logger.info("Firebase Admin SDK initialized successfully.")
        else:
            logger.warning(
                f"Firebase credentials file not found at '{cred_path}'. "
                "Running in sandbox / mock notification mode."
            )
            firebase_initialized = False
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin SDK: {str(e)}")
        firebase_initialized = False

    return firebase_initialized
