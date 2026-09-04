from typing import List
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    PROJECT_NAME: str = "VANET Misbehavior Detection & Trust Management System"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = "super_secure_development_secret_key_change_in_production_key"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 10080  # 7 Days in minutes
    
    # CORS Origins (JSON list or comma separated)
    BACKEND_CORS_ORIGINS: List[str] = ["*"]

    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres_secure_pass@db:5432/vanet_db"

    # Redis URL
    REDIS_URL: str = "redis://redis:6379/0"

    # Firebase Messaging Service Account JSON Placeholder
    FIREBASE_CREDENTIALS_JSON: str = '{"type": "service_account", "project_id": "vanet-firebase-project"}'

    # Google Maps SDK key
    GOOGLE_MAPS_API_KEY: str = "AIzaSyYourGoogleMapsAPIKeyHerePlaceholder"

    model_config = SettingsConfigDict(
        case_sensitive=True,
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
