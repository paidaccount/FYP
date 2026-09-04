import uuid
from datetime import datetime
from typing import Any, Dict, Optional
from pydantic import BaseModel, ConfigDict

class RouteBase(BaseModel):
    start_lat: float
    start_lng: float
    end_lat: float
    end_lng: float
    route_geometry_geojson: Dict[str, Any]
    distance_meters: float
    estimated_duration_seconds: float
    is_preempted_active: Optional[bool] = False

class RouteCreate(RouteBase):
    vehicle_id: uuid.UUID

class RouteUpdate(BaseModel):
    start_lat: Optional[float] = None
    start_lng: Optional[float] = None
    end_lat: Optional[float] = None
    end_lng: Optional[float] = None
    route_geometry_geojson: Optional[Dict[str, Any]] = None
    distance_meters: Optional[float] = None
    estimated_duration_seconds: Optional[float] = None
    is_preempted_active: Optional[bool] = None

class RouteResponse(RouteBase):
    id: uuid.UUID
    vehicle_id: uuid.UUID
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
