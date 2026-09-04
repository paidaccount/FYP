import uuid
from typing import Any, Dict, TYPE_CHECKING
from sqlalchemy import Numeric, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle

class Route(Base):
    __tablename__ = "routes"

    vehicle_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    start_lat: Mapped[float] = mapped_column(
        Numeric(10, 8),
        nullable=False
    )
    start_lng: Mapped[float] = mapped_column(
        Numeric(11, 8),
        nullable=False
    )
    end_lat: Mapped[float] = mapped_column(
        Numeric(10, 8),
        nullable=False
    )
    end_lng: Mapped[float] = mapped_column(
        Numeric(11, 8),
        nullable=False
    )
    route_geometry_geojson: Mapped[Dict[str, Any]] = mapped_column(
        JSONB,
        nullable=False
    )
    distance_meters: Mapped[float] = mapped_column(
        Numeric(8, 2),
        nullable=False
    )
    estimated_duration_seconds: Mapped[float] = mapped_column(
        Numeric(6, 1),
        nullable=False
    )
    is_preempted_active: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )

    # Relationships
    vehicle: Mapped["Vehicle"] = relationship(back_populates="routes")
