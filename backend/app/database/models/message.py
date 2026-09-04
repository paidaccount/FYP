import uuid
from datetime import datetime
from typing import Optional, TYPE_CHECKING
from sqlalchemy import String, Numeric, ForeignKey, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle
    from app.database.models.prediction import Prediction

class VehicleMessage(Base):
    __tablename__ = "vehicle_messages"

    vehicle_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="CASCADE"),
        index=True,
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
    speed: Mapped[float] = mapped_column(
        Numeric(6, 2),
        nullable=False
    )
    heading: Mapped[float] = mapped_column(
        Numeric(5, 2),
        nullable=False
    )
    timestamp: Mapped[datetime] = mapped_column(
        DateTime,
        nullable=False
    )
    message_type: Mapped[str] = mapped_column(
        String(20),
        default="BSM",
        nullable=False
    )
    signature: Mapped[str] = mapped_column(
        String,
        nullable=False
    )

    # Relationships
    vehicle: Mapped["Vehicle"] = relationship(back_populates="messages")
    prediction: Mapped[Optional["Prediction"]] = relationship(
        back_populates="message",
        cascade="all, delete-orphan"
    )
