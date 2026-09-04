from app.database.db import Base
from app.database.models.user import User
from app.database.models.vehicle import Vehicle
from app.database.models.message import VehicleMessage
from app.database.models.prediction import Prediction
from app.database.models.trust import TrustScore
from app.database.models.emergency import EmergencyVehicle
from app.database.models.alert import Alert
from app.database.models.attack_log import AttackLog
from app.database.models.report import Report
from app.database.models.explanation import AIExplanation
from app.database.models.route import Route
from app.database.models.notification import NotificationHistory
from app.database.models.device_token import DeviceToken

__all__ = [
    "Base",
    "User",
    "Vehicle",
    "VehicleMessage",
    "Prediction",
    "TrustScore",
    "EmergencyVehicle",
    "Alert",
    "AttackLog",
    "Report",
    "AIExplanation",
    "Route",
    "NotificationHistory",
    "DeviceToken",
]
