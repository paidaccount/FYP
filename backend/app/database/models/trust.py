import uuid
from typing import TYPE_CHECKING
from sqlalchemy import Numeric, String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle

class TrustScore(Base):
    __tablename__ = "trust_scores"

    vehicle_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("vehicles.id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    score: Mapped[float] = mapped_column(
        Numeric(3, 2),
        nullable=False
    )
    update_reason: Mapped[str] = mapped_column(
        String(255),
        nullable=False
    )

    # Relationships
    vehicle: Mapped["Vehicle"] = relationship(back_populates="trust_scores")
