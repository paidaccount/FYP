import uuid
from typing import Any, Dict, TYPE_CHECKING
from sqlalchemy import String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle

class AttackLog(Base):
    __tablename__ = "attack_logs"

    offender_vehicle_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    detected_attack_type: Mapped[str] = mapped_column(
        String(100),
        nullable=False
    )
    evidence_data_json: Mapped[Dict[str, Any]] = mapped_column(
        JSONB,
        nullable=False
    )

    # Relationships
    offender: Mapped["Vehicle"] = relationship(back_populates="attack_logs")
