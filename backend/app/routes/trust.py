from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Dict, Any, List
from app.database.store import TRUST_SCORES, VEHICLES
from app.services.trust_engine import TrustEngine

router = APIRouter()

class TrustUpdatePayload(BaseModel):
    vehicle_id: str
    prediction: int
    attack_type: str
    xai_lime_values: Dict[str, float] = Field(default_factory=dict)
    message_features: Dict[str, Any] = Field(default_factory=dict)

@router.get("/ranking")
def get_trust_ranking():
    rankings = []
    for veh_id, score_record in TRUST_SCORES.items():
        rankings.append({
            "vehicle_id": veh_id,
            "trust_score": score_record["current_score"],
            "trust_status": score_record["trust_status"]
        })
        
    # Sort highest trust score first
    rankings.sort(key=lambda x: x["trust_score"], reverse=True)
    return rankings

@router.get("/{vehicle_id}")
def get_vehicle_trust(vehicle_id: str):
    # Retrieve current score details
    if vehicle_id not in TRUST_SCORES:
        # Fallback to default starting score if registered
        if vehicle_id in VEHICLES:
            return {
                "vehicle_id": vehicle_id,
                "trust_score": 100.0,
                "status": "Trusted Vehicle",
                "attack_history": [],
                "trust_trend": [100.0]
            }
        raise HTTPException(status_code=404, detail="Vehicle trust record not found.")

    score_record = TRUST_SCORES[vehicle_id]
    engine = TrustEngine()
    history = engine.history_manager.load_history(vehicle_id)

    return {
        "vehicle_id": vehicle_id,
        "trust_score": score_record["current_score"],
        "status": score_record["trust_status"],
        "attack_history": history.get("attack_history", []),
        "trust_trend": history.get("trust_history", [100.0])
    }

@router.post("/update")
def update_trust_score(payload: TrustUpdatePayload):
    engine = TrustEngine()
    db_record = engine.process_telemetry_event(
        vehicle_id=payload.vehicle_id,
        prediction=payload.prediction,
        attack_type=payload.attack_type,
        xai_lime_values=payload.xai_lime_values,
        message_features=payload.message_features
    )
    
    TRUST_SCORES[payload.vehicle_id] = db_record
    return {"message": "Trust score updated successfully", "trust": db_record}
