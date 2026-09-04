import uuid
from typing import List, Optional, TYPE_CHECKING
from sqlalchemy import String, Numeric, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.database.db import Base

if TYPE_CHECKING:
    from app.database.models.user import User
    from app.database.models.message import VehicleMessage
    from app.database.models.trust import TrustScore
    from app.database.models.emergency import EmergencyVehicle
    from app.database.models.alert import Alert
    from app.database.models.attack_log import AttackLog
    from app.database.models.report import Report
    from app.database.models.route import Route

class Vehicle(Base):
    __tablename__ = "vehicles"

    owner_id: Mapped[Optional[uuid.UUID]] = mapped_column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="SET NULL"),
        nullable=True
    )
    license_plate: Mapped[str] = mapped_column(
        String(50),
        unique=True,
        index=True,
        nullable=False
    )
    vehicle_type: Mapped[str] = mapped_column(
        String(50),
        nullable=False
    )
    status: Mapped[str] = mapped_column(
        String(30),
        default="ACTIVE",
        nullable=False
    )
    cert_hash: Mapped[str] = mapped_column(
        String(64),
        index=True,
        nullable=False
    )
    public_key: Mapped[str] = mapped_column(
        String,
        nullable=False
    )
    trust_score: Mapped[float] = mapped_column(
        Numeric(3, 2),
        default=1.00,
        nullable=False
    )

    # Relationships
    owner: Mapped[Optional["User"]] = relationship(back_populates="vehicles")
    messages: Mapped[List["VehicleMessage"]] = relationship(
        back_populates="vehicle",
        cascade="all, delete-orphan"
    )
    trust_scores: Mapped[List["TrustScore"]] = relationship(
        back_populates="vehicle",
        cascade="all, delete-orphan"
    )
    emergency_profile: Mapped[Optional["EmergencyVehicle"]] = relationship(
        back_populates="vehicle",
        cascade="all, delete-orphan"
    )
    alerts: Mapped[List["Alert"]] = relationship(
        back_populates="vehicle",
        cascade="all, delete-orphan"
    )
    attack_logs: Mapped[List["AttackLog"]] = relationship(
        back_populates="offender",
        cascade="all, delete-orphan"
    )
    routes: Mapped[List["Route"]] = relationship(
        back_populates="vehicle",
        cascade="all, delete-orphan"
    )
