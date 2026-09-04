import uuid
import pandas as pd
from datetime import datetime
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import Dict, Any
from app.database.store import VEHICLES, MESSAGES, PREDICTIONS, TRUST_SCORES
from app.routes.predictions import get_model
from app.services.xai.xai_pipeline import XAIPipeline
from app.services.trust_engine import TrustEngine
from app.routes.websocket import broadcast_update

router = APIRouter()

class MessagePayloadSchema(BaseModel):
    vehicle_id: str
    timestamp: float = Field(default_factory=lambda: datetime.utcnow().timestamp())
    position: Dict[str, float] = Field({"x": 0.0, "y": 0.0})
    speed: float = 0.0
    acceleration: float = 0.0
    direction: float = 0.0
    message_type: str = "Standard"

@router.post("/", status_code=status.HTTP_201_CREATED)
def receive_message(payload: MessagePayloadSchema):
    # 1. Message Validation
    if not payload.vehicle_id:
        raise HTTPException(status_code=400, detail="Vehicle ID is required.")
        
    # Check if vehicle exists, if not register it
    if payload.vehicle_id not in VEHICLES:
        VEHICLES[payload.vehicle_id] = {
            "vehicle_id": payload.vehicle_id,
            "vehicle_type": "Standard",
            "location": payload.position,
            "speed": payload.speed,
            "direction": payload.direction,
            "status": "ACTIVE"
        }
    else:
        VEHICLES[payload.vehicle_id]["location"] = payload.position
        VEHICLES[payload.vehicle_id]["speed"] = payload.speed
        VEHICLES[payload.vehicle_id]["direction"] = payload.direction

    # 2. ML Prediction Inference
    model = get_model()
    
    # Calculate anomaly checks indicators
    speed_anomaly = 0.0
    if payload.speed > 40.0:
        speed_anomaly = (payload.speed - 30.0) / 5.0
        
    pos_anomaly = 0.0
    gps_incon = 0.0
    if abs(payload.position.get("x", 0.0)) > 1000.0 or abs(payload.position.get("y", 0.0)) > 1000.0:
        pos_anomaly = 4.5
        gps_incon = 3.0

    freq_anomaly = 0.0
    comm_score = 0.0
    if payload.message_type == "Fake Emergency":
        freq_anomaly = 5.0
        comm_score = 4.0

    features = {
        "speed": payload.speed,
        "acceleration": payload.acceleration,
        "speed_anomaly_score": speed_anomaly,
        "position_anomaly_score": pos_anomaly,
        "GPS_consistency": gps_incon,
        "message_frequency_anomaly": freq_anomaly,
        "communication_behavior_score": comm_score
    }
    
    df = pd.DataFrame([{
        "speed": payload.speed,
        "acceleration": payload.acceleration,
        "speed_anomaly_score": speed_anomaly,
        "position_anomaly_score": pos_anomaly,
        "GPS_consistency": gps_incon,
        "message_frequency_anomaly": freq_anomaly
    }])
    
    pred_val = int(model.predict(df)[0])
    proba = float(model.predict_proba(df)[0][pred_val])
    
    attack_type = "NONE"
    if pred_val == 1:
        if pos_anomaly > 2.0:
            attack_type = "position_anomaly"
        elif speed_anomaly > 2.0:
            attack_type = "speed_anomaly"
        else:
            attack_type = "message_frequency_anomaly"

    # 3. Explainable AI Pipeline
    prediction_id = str(uuid.uuid4())
    xai_pipeline = XAIPipeline()
    
    # Run explanation mapping
    xai_result = xai_pipeline.explain_prediction(
        model=model,
        features_df=df,
        prediction_uuid=prediction_id
    )
    
    # Save explanation record
    PREDICTIONS[prediction_id] = {
        "prediction_id": prediction_id,
        "vehicle_id": payload.vehicle_id,
        "prediction": "Malicious Vehicle" if pred_val == 1 else "Normal Vehicle",
        "confidence": round(proba * 100.0, 1),
        "attack_type": attack_type,
        "shap_values": xai_result.get("shap_values", {}),
        "lime_values": xai_result.get("lime_values", {}),
        "generated_reason": xai_result.get("generated_reason", "Vehicle behavior is normal."),
        "timestamp": datetime.utcnow().isoformat()
    }

    # 4. Trust Score Update
    trust_engine = TrustEngine()
    db_trust = trust_engine.process_telemetry_event(
        vehicle_id=payload.vehicle_id,
        prediction=pred_val,
        attack_type=attack_type,
        xai_lime_values=xai_result.get("lime_values", {}),
        message_features=features
    )
    
    TRUST_SCORES[payload.vehicle_id] = db_trust

    # Trigger Event Notifications
    from app.services.event_listener import VANETEventListener
    listener = VANETEventListener()
    
    if pred_val == 1:
        listener.on_malicious_detected(
            vehicle_id=payload.vehicle_id,
            attack_type=attack_type,
            confidence=round(proba * 100.0, 1),
            trust_score=db_trust["current_score"]
        )
    
    previous_score = db_trust.get("previous_score", 100.0)
    current_score = db_trust.get("current_score", 100.0)
    if current_score < previous_score and current_score < 80.0:
        listener.on_trust_decayed(
            vehicle_id=payload.vehicle_id,
            previous_score=previous_score,
            new_score=current_score,
            reason=db_trust.get("reason", "Anomalous telemetry behavior detected.")
        )

    # Save Message details to store
    msg_record = {
        "message_id": str(uuid.uuid4()),
        **payload.model_dump(),
        "prediction_id": prediction_id,
        "trust_score": db_trust["current_score"]
    }
    MESSAGES.append(msg_record)

    # 5. Broadcast real-time status update to connected WebSocket clients
    broadcast_update({
        "event_type": "TELEMETRY_UPDATE",
        "vehicle_id": payload.vehicle_id,
        "location": payload.position,
        "prediction": "Malicious Vehicle" if pred_val == 1 else "Normal Vehicle",
        "attack_type": attack_type,
        "trust_score": db_trust["current_score"],
        "trust_status": db_trust["trust_status"]
    })

    return {
        "prediction": "Malicious Vehicle" if pred_val == 1 else "Normal Vehicle",
        "confidence": round(proba * 100.0, 1),
        "attack_type": attack_type,
        "trust_score": db_trust["current_score"]
    }
