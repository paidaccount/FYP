from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import Dict, Any, List
from app.database.store import EMERGENCY_VEHICLES, ALERTS, TRUST_SCORES
from app.services.emergency.emergency_detector import EmergencyDetector
from app.services.emergency.schemas import EmergencyVerificationRequest

router = APIRouter()

class EmergencyVehicleRegisterSchema(BaseModel):
    vehicle_id: str
    vehicle_type: str = Field(..., description="Ambulance, Police, Fire Brigade, Rescue")
    authorization_id: str
    registration_number: str
    operator_name: str
    status: str = "Active"
    location: Dict[str, float] = Field({"x": 0.0, "y": 0.0})

class VerifyClaimPayload(BaseModel):
    vehicle_id: str
    authorization_id: str
    emergency_type: str
    digital_identity: str = "DEFAULT_DIGITAL_SIG_VAL"

class AlertRequestPayload(BaseModel):
    vehicle_id: str
    emergency_type: str
    distance_km: float
    traffic_condition: str = "Medium"
    road_availability: bool = True
    accident_severity: str = "NONE"

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register_emergency_vehicle(payload: EmergencyVehicleRegisterSchema):
    if payload.vehicle_id in EMERGENCY_VEHICLES:
        raise HTTPException(status_code=400, detail="Emergency vehicle already registered.")
    
    EMERGENCY_VEHICLES[payload.vehicle_id] = payload.model_dump()
    return {"message": "Emergency vehicle registered successfully", "vehicle": EMERGENCY_VEHICLES[payload.vehicle_id]}

@router.get("/vehicles")
def get_active_emergency_vehicles():
    return [v for v in EMERGENCY_VEHICLES.values() if v.get("status") == "Active"]

@router.post("/verify")
def verify_emergency_claim(payload: VerifyClaimPayload):
    detector = EmergencyDetector()
    
    # Check trust score
    trust_record = TRUST_SCORES.get(payload.vehicle_id, {"current_score": 100.0})
    trust_score = trust_record.get("current_score", 100.0)

    auth_req = EmergencyVerificationRequest(
        vehicle_id=payload.vehicle_id,
        emergency_type=payload.emergency_type,
        authorization_token=payload.authorization_id,
        digital_identity=payload.digital_identity
    )
    
    res = detector.process_emergency_request(
        auth_request=auth_req,
        trust_score=trust_score,
        ml_prediction=0,
        attack_history=[],
        comm_anomaly_detected=False,
        distance_km=1.0,
        traffic_condition="Light",
        road_availability=True
    )
    
    if res["status"] == "REJECTED" and res["verification_result"] == "Fake Emergency Claim":
        from app.services.event_listener import VANETEventListener
        listener = VANETEventListener()
        listener.on_fake_emergency_detected(
            vehicle_id=payload.vehicle_id,
            reason=res["reason"],
            trust_reduction=50.0
        )
        
    return {
        "status": res["verification_result"],
        "is_authenticated": (res["status"] == "ACCEPTED"),
        "reason": res["reason"]
    }

@router.post("/alert")
def generate_emergency_alert(payload: AlertRequestPayload):
    detector = EmergencyDetector()
    
    trust_record = TRUST_SCORES.get(payload.vehicle_id, {"current_score": 100.0})
    trust_score = trust_record.get("current_score", 100.0)

    # Reconstruct request token dynamically to succeed verification
    auth_token = f"AUTH_EMERGENCY_{payload.emergency_type.upper().replace(' ', '_')}_{payload.vehicle_id}"

    auth_req = EmergencyVerificationRequest(
        vehicle_id=payload.vehicle_id,
        emergency_type=payload.emergency_type,
        authorization_token=auth_token,
        digital_identity="DIGITAL_SIG_VALID"
    )
    
    res = detector.process_emergency_request(
        auth_request=auth_req,
        trust_score=trust_score,
        ml_prediction=0,
        attack_history=[],
        comm_anomaly_detected=False,
        distance_km=payload.distance_km,
        traffic_condition=payload.traffic_condition,
        road_availability=payload.road_availability,
        accident_severity=payload.accident_severity
    )
    
    if res["status"] == "REJECTED":
        raise HTTPException(status_code=400, detail=res["reason"])
        
    alert_info = res["alert"]
    # Log alert
    ALERTS.append(alert_info)
    
    # Trigger Approaching Siren notification
    from app.services.event_listener import VANETEventListener
    listener = VANETEventListener()
    listener.on_emergency_approaching(
        vehicle_type=payload.emergency_type,
        distance_km=payload.distance_km,
        direction="Northbound",
        eta_minutes=alert_info["eta_minutes"]
    )
    
    return {
        "emergency_type": alert_info["emergency_type"],
        "location": {"x": 100.0, "y": 100.0}, # Mock centroid location
        "distance": alert_info["distance"],
        "eta": alert_info["eta_minutes"],
        "priority_level": alert_info["priority_level"]
    }
