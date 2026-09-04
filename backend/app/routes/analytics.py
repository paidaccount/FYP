from fastapi import APIRouter
from app.database.store import VEHICLES, TRUST_SCORES, EMERGENCY_VEHICLES, ALERTS

router = APIRouter()

@router.get("/dashboard")
def get_dashboard_analytics():
    # 1. Total registered vehicles
    total_vehicles = len(VEHICLES)

    # 2. Count by trust status categories
    malicious = 0
    trusted = 0
    for v in TRUST_SCORES.values():
        score = v.get("current_score", 100.0)
        if score < 40.0:
            malicious += 1
        elif score >= 80.0:
            trusted += 1

    # 3. Total emergency vehicles
    total_emergency = len(EMERGENCY_VEHICLES)

    # 4. Total active alerts
    total_alerts = len(ALERTS)

    return {
        "total_vehicles": total_vehicles,
        "malicious_vehicles": malicious,
        "trusted_vehicles": trusted,
        "emergency_vehicles": total_emergency,
        "active_alerts": total_alerts
    }
