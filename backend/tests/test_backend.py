import pytest
from httpx import AsyncClient

@pytest.mark.anyio
async def test_health_check(client: AsyncClient):
    """Tests health check diagnostics endpoint."""
    response = await client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

@pytest.mark.anyio
async def test_auth_login(client: AsyncClient):
    """Tests JWT authentication endpoints."""
    payload = {
        "username": "admin",
        "password": "securepassword123"
    }
    response = await client.post("/api/v1/auth/login", json=payload)
    assert response.status_code == 200
    assert "access_token" in response.json()
    assert response.json()["role"] == "ADMIN"

@pytest.mark.anyio
async def test_vehicle_management(client: AsyncClient):
    """Tests vehicle registration and listing."""
    payload = {
        "vehicle_id": "V_PYTEST_111",
        "vehicle_type": "Standard",
        "location": {"x": 10.0, "y": 20.0},
        "speed": 15.0,
        "direction": 90.0,
        "status": "ACTIVE"
    }
    response = await client.post("/api/v1/vehicles/", json=payload)
    assert response.status_code == 201
    
    # List vehicles
    res_list = await client.get("/api/v1/vehicles/")
    assert res_list.status_code == 200
    assert len(res_list.json()) >= 1

@pytest.mark.anyio
async def test_prediction_inference(client: AsyncClient):
    """Tests ML classification inference analyze endpoint."""
    payload = {
        "features": {
            "speed": 45.0,
            "acceleration": 1.2,
            "speed_anomaly_score": 4.5,
            "position_anomaly_score": 0.0,
            "GPS_consistency": 0.0,
            "message_frequency_anomaly": 0.0,
            "communication_behavior_score": 0.0
        }
    }
    response = await client.post("/api/v1/prediction/analyze", json=payload)
    assert response.status_code == 200
    assert "prediction" in response.json()

@pytest.mark.anyio
async def test_xai_explanation(client: AsyncClient):
    """Tests explainability reports retrieval."""
    response = await client.get("/api/v1/xai/explanation/mock_pred_123")
    assert response.status_code == 200
    assert "shap_features" in response.json()

@pytest.mark.anyio
async def test_trust_score(client: AsyncClient):
    """Tests trust details and update endpoints."""
    # Run update
    payload = {
        "vehicle_id": "V_PYTEST_111",
        "prediction": 1,
        "attack_type": "speed_anomaly",
        "xai_lime_values": {"speed_anomaly_score": 0.45},
        "message_features": {"speed_anomaly_score": 4.5}
    }
    response = await client.post("/api/v1/trust/update", json=payload)
    assert response.status_code == 200

    # Get trust ranking list
    res_rank = await client.get("/api/v1/trust/ranking")
    assert res_rank.status_code == 200
    assert len(res_rank.json()) >= 1

@pytest.mark.anyio
async def test_emergency_verification(client: AsyncClient):
    """Tests emergency claim authentication checks."""
    payload = {
        "vehicle_id": "AMB_PYTEST_222",
        "authorization_id": "AUTH_EMERGENCY_AMBULANCE_AMB_PYTEST_222",
        "emergency_type": "Ambulance"
    }
    response = await client.post("/api/v1/emergency/verify", json=payload)
    assert response.status_code == 200
    assert "is_authenticated" in response.json()

@pytest.mark.anyio
async def test_route_recommendation(client: AsyncClient):
    """Tests routing cost calculations detour endpoints."""
    payload = {
        "vehicle_id": "AMB_PYTEST_222",
        "source": "A",
        "destination": "F",
        "vehicle_type": "Ambulance",
        "traffic_condition": "Medium"
    }
    response = await client.post("/api/v1/recommend", json=payload)
    assert response.status_code == 200
    assert "recommended_route" in response.json()

@pytest.mark.anyio
async def test_notifications_history(client: AsyncClient):
    """Tests device registration and notification history fetch."""
    # Register device token
    payload = {
        "user_id": "user_pytest_abc",
        "token": "MOCK_TOKEN_PYTEST_FCM_KEY_XYZ",
        "platform": "ios"
    }
    response = await client.post("/api/v1/notifications/register-token", json=payload)
    assert response.status_code == 201

    # Fetch notification histories
    res_hist = await client.get("/api/v1/notifications/history")
    assert res_hist.status_code == 200
