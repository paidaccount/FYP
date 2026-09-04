import uuid
from typing import Optional, TYPE_CHECKING
from sqlalchemy import Boolean, Numeric, String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.message import VehicleMessage
    from app.database.models.explanation import AIExplanation

class Prediction(Base):
    __tablename__ = "predictions"

    message_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicle_messages.id", ondelete="CASCADE"),
        unique=True,
        nullable=False
    )
    is_malicious: Mapped[bool] = mapped_column(
        Boolean,
        nullable=False
    )
    probability: Mapped[float] = mapped_column(
        Numeric(5, 4),
        nullable=False
    )
    model_version: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )

    # Relationships
    message: Mapped["VehicleMessage"] = relationship(back_populates="prediction")
    explanation: Mapped[Optional["AIExplanation"]] = relationship(
        back_populates="prediction",
        cascade="all, delete-orphan"
    )
