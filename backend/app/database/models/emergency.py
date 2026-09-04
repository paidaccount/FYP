import uuid
from datetime import datetime
from typing import TYPE_CHECKING
from sqlalchemy import String, Integer, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle

class EmergencyVehicle(Base):
    __tablename__ = "emergency_vehicles"

    vehicle_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="CASCADE"),
        unique=True,
        nullable=False
    )
    department: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    certification_expiry: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )
    authorization_status: Mapped[str] = mapped_column(
        String(30),
        default="PENDING",
        nullable=False
    )
    priority_level: Mapped[int] = mapped_column(
        Integer,
        default=1,
        nullable=False
    )

    # Relationships
    vehicle: Mapped["Vehicle"] = relationship(back_populates="emergency_profile")
