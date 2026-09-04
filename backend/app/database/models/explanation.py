import uuid
from typing import Any, Dict, TYPE_CHECKING
from sqlalchemy import String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.prediction import Prediction

class AIExplanation(Base):
    __tablename__ = "ai_explanations"

    prediction_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("predictions.id", ondelete="CASCADE"),
        unique=True,
        nullable=False
    )
    explainer_type: Mapped[str] = mapped_column(
        String(20),
        nullable=False
    )
    explanation_payload_json: Mapped[Dict[str, Any]] = mapped_column(
        JSONB,
        nullable=False
    )

    # Relationships
    prediction: Mapped["Prediction"] = relationship(back_populates="explanation")
