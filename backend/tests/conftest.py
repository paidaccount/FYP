import pytest
from unittest.mock import AsyncMock, MagicMock
from httpx import AsyncClient
from app.main import app
from app.dependencies.database import get_db

@pytest.fixture(scope="session")
def anyio_backend():
    return "asyncio"

@pytest.fixture
async def client():
    """
    Overrides get_db session dependency to provide a mock database
    execution context, ensuring tests do not rely on local databases.
    """
    async def override_get_db():
        mock_db = AsyncMock()
        mock_result = MagicMock()
        # Mocking database connection test "SELECT 1" -> scalar() returns 1
        mock_result.scalar.return_value = 1
        mock_db.execute.return_value = mock_result
        yield mock_db

    from httpx import ASGITransport
    app.dependency_overrides[get_db] = override_get_db
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as ac:
        yield ac
    app.dependency_overrides.clear()
