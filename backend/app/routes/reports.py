from fastapi import APIRouter, HTTPException
from typing import Dict, Any, List
from app.database.store import VEHICLES, MESSAGES, PREDICTIONS, TRUST_SCORES, EMERGENCY_VEHICLES
from app.services.trust_engine import TrustEngine

router = APIRouter()

@router.get("/security")
def get_security_report():
    # 1. Count malicious vehicles
    malicious_count = sum(1 for v in TRUST_SCORES.values() if v.get("current_score", 100.0) < 40.0)

    # 2. Count attack distributions
    attack_dist = {}
    for msg in MESSAGES:
        pred_id = msg.get("prediction_id")
        if pred_id in PREDICTIONS:
            attack = PREDICTIONS[pred_id].get("attack_type", "NONE")
            if attack != "NONE":
                attack_dist[attack] = attack_dist.get(attack, 0) + 1

    # 3. Calculate trust statistics
    scores = [v.get("current_score", 100.0) for v in TRUST_SCORES.values()]
    avg_trust = sum(scores) / len(scores) if scores else 100.0

    # 4. Count emergency events
    emergency_events = list(EMERGENCY_VEHICLES.values())

    return {
        "malicious_vehicle_count": malicious_count,
        "attack_distribution": attack_dist,
        "trust_statistics": {
            "average_trust_score": round(avg_trust, 2),
            "total_evaluated_vehicles": len(TRUST_SCORES)
        },
        "emergency_events": emergency_events
    }

@router.get("/vehicle/{vehicle_id}")
def get_vehicle_report(vehicle_id: str):
    if vehicle_id not in VEHICLES:
        raise HTTPException(status_code=404, detail="Vehicle not found in registered records.")

    # Fetch message logs
    vehicle_msgs = [m for m in MESSAGES if m.get("vehicle_id") == vehicle_id]

    # Fetch trust engine history
    engine = TrustEngine()
    history = engine.history_manager.load_history(vehicle_id)

    return {
        "vehicle_id": vehicle_id,
        "details": VEHICLES[vehicle_id],
        "message_logs": vehicle_msgs,
        "trust_history": history.get("trust_history", [100.0]),
        "attack_history": history.get("attack_history", [])
    }
