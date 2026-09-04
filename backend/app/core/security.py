from datetime import datetime, timedelta, timezone
from typing import Any, Union, Dict
from jose import jwt, JWTError
from passlib.context import CryptContext
from app.core.config import settings

# Cryptographic context configuration for bcrypt password hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

ALGORITHM = "HS256"

# User Role Classifications
class UserRole:
    ADMIN = "ADMIN"
    TRAFFIC_OFFICER = "TRAFFIC_OFFICER"
    EMERGENCY_OFFICER = "EMERGENCY_OFFICER"
    VIEWER = "VIEWER"

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    Verifies a plain text password against its bcrypt hashed equivalent.
    """
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """
    Computes a bcrypt hash for a plain text password.
    """
    return pwd_context.hash(password)

def create_access_token(subject: Union[str, Any], role: str, expires_delta: timedelta = None) -> str:
    """
    Generates a cryptographically signed JWT access token for a subject and role.
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "role": role,
        "type": "access"
    }
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def create_refresh_token(subject: Union[str, Any], role: str, expires_delta: timedelta = None) -> str:
    """
    Generates a long-lived JWT refresh token used to request new access tokens.
    """
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(days=30) # Refresh token expires in 30 days
        
    to_encode = {
        "exp": expire,
        "sub": str(subject),
        "role": role,
        "type": "refresh"
    }
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def decode_token(token: str) -> Dict[str, Any]:
    """
    Decodes and verifies a JWT token. Raises JWTError if invalid or expired.
    """
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except JWTError as e:
        raise e
