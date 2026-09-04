from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_vehicle_registration():
    print("\n--- Testing Vehicle Registration API ---")
    payload = {
        "vehicle_id": "TEST_VEH_999",
        "vehicle_type": "Standard",
        "location": {"x": 10.0, "y": 20.0},
        "speed": 12.5,
        "direction": 45.0,
        "status": "ACTIVE"
    }
    
    # Test POST /api/v1/vehicles/
    res_post = client.post("/api/v1/vehicles/", json=payload)
    print(f"POST /api/v1/vehicles/ status: {res_post.status_code}")
    print(f"Response: {res_post.json()}")
    assert res_post.status_code == 201
    
    # Test GET /api/v1/vehicles/
    res_get = client.get("/api/v1/vehicles/")
    print(f"GET /api/v1/vehicles/ status: {res_get.status_code}")
    print(f"Count of registered vehicles: {len(res_get.json())}")
    assert res_get.status_code == 200
    assert len(res_get.json()) >= 1

def test_prediction_analyze():
    print("\n--- Testing Misbehavior Detection API ---")
    payload = {
        "features": {
            "speed": 35.0,
            "acceleration": 2.1,
            "speed_anomaly_score": 4.5,
            "position_anomaly_score": 0.0,
            "GPS_consistency": 0.0,
            "message_frequency_anomaly": 0.0,
            "communication_behavior_score": 0.0
        }
    }
    res = client.post("/api/v1/prediction/analyze", json=payload)
    print(f"POST /api/v1/prediction/analyze status: {res.status_code}")
    print(f"Response: {res.json()}")
    assert res.status_code == 200
    assert "prediction" in res.json()
    assert "confidence" in res.json()

def test_xai_explanation():
    print("\n--- Testing Explainable AI API ---")
    prediction_id = "mock_pred_123"
    res = client.get(f"/api/v1/xai/explanation/{prediction_id}")
    print(f"GET /api/v1/xai/explanation/{prediction_id} status: {res.status_code}")
    print(f"Response: {res.json()}")
    assert res.status_code == 200
    assert "shap_features" in res.json()
    assert "human_explanation" in res.json()

def test_trust_management():
    print("\n--- Testing Trust Management API ---")
    # Test trust score update
    payload = {
        "vehicle_id": "TEST_VEH_999",
        "prediction": 1,
        "attack_type": "speed_anomaly",
        "xai_lime_values": {"speed_anomaly_score": 0.45},
        "message_features": {"speed_anomaly_score": 4.5}
    }
    res_update = client.post("/api/v1/trust/update", json=payload)
    print(f"POST /api/v1/trust/update status: {res_update.status_code}")
    print(f"Response: {res_update.json()}")
    assert res_update.status_code == 200
    
    # Test GET /api/v1/trust/{vehicle_id}
    res_get = client.get("/api/v1/trust/TEST_VEH_999")
    print(f"GET /api/v1/trust/TEST_VEH_999 status: {res_get.status_code}")
    print(f"Response: {res_get.json()}")
    assert res_get.status_code == 200
    assert res_get.json()["trust_score"] < 100.0 # Penality should be applied

def test_emergency_verification():
    print("\n--- Testing Emergency Vehicle APIs ---")
    # Register emergency vehicle
    payload_reg = {
        "vehicle_id": "TEST_AMB_001",
        "vehicle_type": "Ambulance",
        "authorization_id": "AUTH_EMERGENCY_AMBULANCE_TEST_AMB_001",
        "registration_number": "REG-AMB-123",
        "operator_name": "Dr. Smith",
        "status": "Active",
        "location": {"x": 0.0, "y": 0.0}
    }
    res_reg = client.post("/api/v1/emergency/register", json=payload_reg)
    print(f"POST /api/v1/emergency/register status: {res_reg.status_code}")
    assert res_reg.status_code == 201

    # Verify emergency claim
    payload_verify = {
        "vehicle_id": "TEST_AMB_001",
        "authorization_id": "AUTH_EMERGENCY_AMBULANCE_TEST_AMB_001",
        "emergency_type": "Ambulance",
        "digital_identity": "DIGITAL_SIG_VALID_KEY_XYZ"
    }
    res_verify = client.post("/api/v1/emergency/verify", json=payload_verify)
    print(f"POST /api/v1/emergency/verify status: {res_verify.status_code}")
    print(f"Response: {res_verify.json()}")
    assert res_verify.status_code == 200
    assert res_verify.json()["is_authenticated"] is True

def test_route_recommendation():
    print("\n--- Testing Route Recommendation APIs ---")
    # Register accident block
    payload_acc = {
        "accident_id": "ACC_TEST_1",
        "location": {"x": 500.0, "y": 500.0},
        "severity": "Critical",
        "affected_roads": ["ROAD_BC"]
    }
    res_acc = client.post("/api/v1/routing/accidents/", json=payload_acc)
    print(f"POST /api/v1/routing/accidents/ status: {res_acc.status_code}")
    assert res_acc.status_code == 201

    # Recommend Route
    payload_route = {
        "vehicle_id": "TEST_AMB_001",
        "source": "A",
        "destination": "F",
        "vehicle_type": "Ambulance",
        "traffic_condition": "Medium"
    }
    res_route = client.post("/api/v1/routing/recommend", json=payload_route)
    print(f"POST /api/v1/routing/recommend status: {res_route.status_code}")
    print(f"Response: {res_route.json()}")
    assert res_route.status_code == 200
    assert "recommended_route" in res_route.json()

def test_reports_and_analytics():
    print("\n--- Testing Reports and Dashboards APIs ---")
    # Security reports
    res_rep = client.get("/api/v1/reports/security")
    print(f"GET /api/v1/reports/security status: {res_rep.status_code}")
    print(f"Response: {res_rep.json()}")
    assert res_rep.status_code == 200

    # Dashboard analytics
    res_ana = client.get("/api/v1/analytics/dashboard")
    print(f"GET /api/v1/analytics/dashboard status: {res_ana.status_code}")
    print(f"Response: {res_ana.json()}")
    assert res_ana.status_code == 200

if __name__ == "__main__":
    test_vehicle_registration()
    test_prediction_analyze()
    test_xai_explanation()
    test_trust_management()
    test_emergency_verification()
    test_route_recommendation()
    test_reports_and_analytics()
    print("\nAll FastAPI Integration Tests Passed Successfully!")
