from sqlalchemy.ext.asyncio import AsyncSession
from app.database.repositories.user_repo import UserRepository
from app.schemas.user import UserCreate
from app.database.models.user import User
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token
from app.core.exceptions import AuthenticationException

class AuthService:
    """
    Coordinates operators authentication, registration checking, 
    and JWT payload packaging.
    """
    def __init__(self, user_repo: UserRepository):
        self.user_repo = user_repo

    async def register_user(self, db: AsyncSession, user_in: UserCreate) -> User:
        existing = await self.user_repo.get_by_email(db, user_in.email)
        if existing:
            raise AuthenticationException("Email already registered.")
        
        # Overwrite plain password with computed bcrypt hash
        user_data = user_in.model_dump()
        user_data["password_hash"] = get_password_hash(user_data.pop("password"))
        
        return await self.user_repo.create(db, obj_in=user_data)

    async def authenticate(self, db: AsyncSession, email: str, password: str) -> User:
        user = await self.user_repo.get_by_email(db, email)
        if not user:
            raise AuthenticationException("Invalid email or password.")
        
        if not verify_password(password, user.password_hash):
            raise AuthenticationException("Invalid email or password.")
            
        return user

    def generate_tokens(self, user: User) -> dict:
        access_token = create_access_token(subject=user.id, role=user.role)
        refresh_token = create_refresh_token(subject=user.id, role=user.role)
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer"
        }
