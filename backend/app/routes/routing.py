from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import Dict, Any, List
from app.database.store import ACCIDENTS, ROUTES
from app.services.routing.route_optimizer import RouteOptimizer

router = APIRouter()

class RouteRecommendPayload(BaseModel):
    vehicle_id: str = "VEH_MOCK"
    source: str = "A"
    destination: str = "F"
    vehicle_type: str = "Standard"
    traffic_condition: str = "Medium"

class AccidentPayload(BaseModel):
    accident_id: str
    location: Dict[str, float] = Field({"x": 500.0, "y": 500.0})
    severity: str = Field("Medium", description="Low, Medium, High, Critical")
    affected_roads: List[str] = Field(..., description="e.g. ['ROAD_BC']")

@router.post("/recommend")
def recommend_route(payload: RouteRecommendPayload):
    optimizer = RouteOptimizer()
    
    # Identify blocked road segments due to active accidents
    blocked_roads = []
    for acc in ACCIDENTS.values():
        blocked_roads.extend(acc.get("affected_roads", []))

    res = optimizer.optimize_route(
        vehicle_id=payload.vehicle_id,
        source=payload.source,
        destination=payload.destination,
        accident_roads=blocked_roads
    )

    if not res.get("recommended_route"):
        raise HTTPException(status_code=400, detail=res["reason"])

    # Log route request
    ROUTES.append(res)
    
    # Trigger Traffic Congestion Event notification if detour reason contains congestion info
    if "traffic" in res["reason"].lower() or "detour" in res["reason"].lower():
        from app.services.event_listener import VANETEventListener
        listener = VANETEventListener()
        listener.on_congestion_detected(
            road_id="CONGESTED_ROAD_SEGMENT",
            detour_road=" -> ".join(res["alternative_route"])
        )

    return {
        "recommended_route": res["recommended_route"],
        "alternative_route": res["alternative_route"],
        "eta": res["eta"],
        "reason": res["reason"]
    }

# Accident endpoints registered under the same router (or mounted separately)
@router.post("/accidents/", status_code=status.HTTP_201_CREATED)
def create_accident(payload: AccidentPayload):
    if payload.accident_id in ACCIDENTS:
        raise HTTPException(status_code=400, detail="Accident event already exists.")
        
    ACCIDENTS[payload.accident_id] = payload.model_dump()
    
    # Trigger Accident Event notification
    from app.services.event_listener import VANETEventListener
    listener = VANETEventListener()
    listener.on_accident_reported(
        accident_id=payload.accident_id,
        location_desc=f"Road segments {payload.affected_roads}",
        severity=payload.severity,
        affected_area=150.0
    )
    
    return {"message": "Accident event logged successfully", "accident": ACCIDENTS[payload.accident_id]}

@router.get("/accidents/")
def get_active_accidents():
    return list(ACCIDENTS.values())
