import uuid
from typing import TYPE_CHECKING
from sqlalchemy import String, Boolean, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.user import User

class NotificationHistory(Base):
    __tablename__ = "notification_history"

    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        index=True,
        nullable=False
    )
    title: Mapped[str] = mapped_column(
        String(150),
        nullable=False
    )
    body: Mapped[str] = mapped_column(
        String,
        nullable=False
    )
    notification_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )
    is_read: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )

    # Relationships
    user: Mapped["User"] = relationship(back_populates="notifications")
