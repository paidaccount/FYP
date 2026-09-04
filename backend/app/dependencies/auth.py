from fastapi import Depends
from fastapi.security import OAuth2PasswordBearer
from jose import jwt, JWTError
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings
from app.core.security import decode_token
from app.core.exceptions import AuthenticationException, AuthorizationException
from app.dependencies.database import get_db
from app.database.repositories.user_repo import UserRepository
from app.database.models.user import User

# OAuth2 password flow scheme mapping
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl=f"{settings.API_V1_STR}/auth/login"
)

user_repo = UserRepository()

async def get_current_user(
    db: AsyncSession = Depends(get_db),
    token: str = Depends(oauth2_scheme)
) -> User:
    """
    Decodes the JWT access token and matches it to a database user.
    """
    try:
        payload = decode_token(token)
        user_id = payload.get("sub")
        token_type = payload.get("type")
        
        if user_id is None or token_type != "access":
            raise AuthenticationException("Could not validate credentials.")
    except JWTError:
        raise AuthenticationException("Could not validate credentials.")

    user = await user_repo.get(db, id=user_id)
    if not user:
        raise AuthenticationException("User not found.")
    return user

class RoleChecker:
    """
    Dependency checker class allowing route-level validation
    of user clearance roles.
    """
    def __init__(self, allowed_roles: list[str]):
        self.allowed_roles = allowed_roles

    def __call__(self, current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in self.allowed_roles:
            raise AuthorizationException("Insufficient privileges to execute this operation.")
        return current_user
