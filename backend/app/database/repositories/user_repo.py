from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.models.user import User
from app.database.repositories.base import BaseRepository

class UserRepository(BaseRepository[User]):
    def __init__(self):
        super().__init__(User)

    async def get_by_email(self, db: AsyncSession, email: str) -> Optional[User]:
        """
        Retrieves user instance by exact matching email string.
        """
        query = select(User).where(User.email == email)
        result = await db.execute(query)
        return result.scalars().first()
