import uuid
from typing import Optional, TYPE_CHECKING
from sqlalchemy import String, Numeric, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle

class Alert(Base):
    __tablename__ = "alerts"

    vehicle_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="SET NULL"),
        index=True,
        nullable=True
    )
    alert_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )
    message: Mapped[str] = mapped_column(
        String,
        nullable=False
    )
    severity: Mapped[str] = mapped_column(
        String(20),
        default="INFO",
        nullable=False
    )
    latitude: Mapped[Optional[float]] = mapped_column(
        Numeric(10, 8),
        nullable=True
    )
    longitude: Mapped[Optional[float]] = mapped_column(
        Numeric(11, 8),
        nullable=True
    )
    is_resolved: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )

    # Relationships
    vehicle: Mapped[Optional["Vehicle"]] = relationship(back_populates="alerts")
