import os
import firebase_admin
from firebase_admin import credentials
from app.core.logging import logger

# Global flag indicating if Firebase Admin is fully initialized
firebase_initialized = False

def initialize_firebase() -> bool:
    """
    Initializes Firebase Admin SDK using service account keys.
    Falls back gracefully if credentials are not configured.
    """
    global firebase_initialized
    if firebase_initialized:
        return True

    # Try loading service account path from environment variables
    cred_path = os.getenv("FIREBASE_CREDENTIALS_PATH", "firebase-service-account.json")
    
    try:
        if os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
            firebase_initialized = True
            logger.info("Firebase Admin SDK initialized successfully.")
        else:
            # Fallback initialization using mock default app settings
            logger.warning(
                f"Firebase credentials file not found at '{cred_path}'. "
                "Running in sandbox / mock notification mode."
            )
            # Try to initialize with mock credentials if possible, else mark as uninitialized
            firebase_initialized = False
    except Exception as e:
        logger.error(f"Failed to initialize Firebase Admin SDK: {str(e)}")
        firebase_initialized = False

    return firebase_initialized
