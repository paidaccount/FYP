import pytest

@pytest.mark.anyio
async def test_health_endpoint(client):
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

@pytest.mark.anyio
async def test_ping_endpoint(client):
    response = await client.get("/api/v1/ping")
    assert response.status_code == 200
    assert response.json() == "pong"

@pytest.mark.anyio
async def test_version_endpoint(client):
    response = await client.get("/api/v1/version")
    assert response.status_code == 200
    data = response.json()
    assert "version" in data
    assert data["version"] == "1.0.0"

@pytest.mark.anyio
async def test_database_connection_endpoint(client):
    response = await client.get("/api/v1/database")
    assert response.status_code == 200
    assert response.json() == {
        "status": "connected",
        "backend": "PostgreSQL with PostGIS"
    }
