import uuid
from typing import Optional, TYPE_CHECKING
from sqlalchemy import String, Numeric, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle

class Report(Base):
    __tablename__ = "reports"

    reporter_vehicle_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    target_vehicle_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="SET NULL"),
        index=True,
        nullable=True
    )
    incident_description: Mapped[str] = mapped_column(
        String,
        nullable=False
    )
    latitude: Mapped[float] = mapped_column(
        Numeric(10, 8),
        nullable=False
    )
    longitude: Mapped[float] = mapped_column(
        Numeric(11, 8),
        nullable=False
    )

    # Relationships
    reporter: Mapped["Vehicle"] = relationship(
        "Vehicle",
        foreign_keys=[reporter_vehicle_id]
    )
    target: Mapped[Optional["Vehicle"]] = relationship(
        "Vehicle",
        foreign_keys=[target_vehicle_id]
    )
