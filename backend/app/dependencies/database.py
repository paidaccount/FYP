from typing import AsyncGenerator
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.db import SessionLocal

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    """
    Dependency generator yielding active transactional database sessions.
    Automatically commits or rolls back transactions when context exits.
    """
    async with SessionLocal() as session:
        try:
            yield session
        finally:
            await session.close()
