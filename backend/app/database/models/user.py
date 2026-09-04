from typing import List, TYPE_CHECKING
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.vehicle import Vehicle
    from app.database.models.notification import NotificationHistory
    from app.database.models.device_token import DeviceToken

class User(Base):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(
        String(255),
        unique=True,
        index=True,
        nullable=False
    )
    password_hash: Mapped[str] = mapped_column(
        String(255),
        nullable=False
    )
    role: Mapped[str] = mapped_column(
        String(50),
        default="DRIVER",
        nullable=False
    )

    # Relationships
    vehicles: Mapped[List["Vehicle"]] = relationship(
        back_populates="owner",
        cascade="all, delete-orphan"
    )
    notifications: Mapped[List["NotificationHistory"]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan"
    )
    device_tokens: Mapped[List["DeviceToken"]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan"
    )
