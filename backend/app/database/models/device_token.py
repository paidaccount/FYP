import uuid
from typing import TYPE_CHECKING
from sqlalchemy import String, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.user import User

class DeviceToken(Base):
    """
    SQLAlchemy database model for client device tokens mapping.
    """
    __tablename__ = "device_tokens"

    id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False
    )
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    token: Mapped[str] = mapped_column(
        String,
        unique=True,
        nullable=False
    )
    platform: Mapped[str] = mapped_column(
        String(20),
        default="android",
        nullable=False
    )

    # Relationships
    user: Mapped["User"] = relationship(back_populates="device_tokens")
