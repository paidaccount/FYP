from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from typing import Dict, List, Optional
from app.database.store import VEHICLES

router = APIRouter()

class VehicleRegisterSchema(BaseModel):
    vehicle_id: str
    vehicle_type: str = Field(..., description="e.g. Ambulance, Standard, Police")
    location: Dict[str, float] = Field({"x": 0.0, "y": 0.0})
    speed: float = 0.0
    direction: float = 0.0
    status: str = "ACTIVE"

class VehicleUpdateSchema(BaseModel):
    vehicle_type: Optional[str] = None
    location: Optional[Dict[str, float]] = None
    speed: Optional[float] = None
    direction: Optional[float] = None
    status: Optional[str] = None

@router.post("/", status_code=status.HTTP_201_CREATED)
def register_vehicle(payload: VehicleRegisterSchema):
    if payload.vehicle_id in VEHICLES:
        raise HTTPException(status_code=400, detail="Vehicle ID already registered.")
    
    VEHICLES[payload.vehicle_id] = payload.model_dump()
    return {"message": "Vehicle registered successfully", "vehicle": VEHICLES[payload.vehicle_id]}

@router.get("/")
def get_all_vehicles():
    return list(VEHICLES.values())

@router.get("/{vehicle_id}")
def get_vehicle(vehicle_id: str):
    if vehicle_id not in VEHICLES:
        raise HTTPException(status_code=404, detail="Vehicle not found.")
    return VEHICLES[vehicle_id]

@router.put("/{vehicle_id}")
def update_vehicle(vehicle_id: str, payload: VehicleUpdateSchema):
    if vehicle_id not in VEHICLES:
        raise HTTPException(status_code=404, detail="Vehicle not found.")
    
    update_data = payload.model_dump(exclude_unset=True)
    VEHICLES[vehicle_id].update(update_data)
    return {"message": "Vehicle updated successfully", "vehicle": VEHICLES[vehicle_id]}

@router.delete("/{vehicle_id}")
def delete_vehicle(vehicle_id: str):
    if vehicle_id not in VEHICLES:
        raise HTTPException(status_code=404, detail="Vehicle not found.")
    
    del VEHICLES[vehicle_id]
    return {"message": "Vehicle removed successfully"}
