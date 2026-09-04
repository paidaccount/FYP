from app.database.repositories.base import BaseRepository
from app.database.repositories.user_repo import UserRepository
from app.database.repositories.vehicle_repo import VehicleRepository
from app.database.repositories.message_repo import VehicleMessageRepository
from app.database.repositories.prediction_repo import PredictionRepository
from app.database.repositories.trust_repo import TrustScoreRepository
from app.database.repositories.emergency_repo import EmergencyVehicleRepository
from app.database.repositories.alert_repo import AlertRepository
from app.database.repositories.attack_log_repo import AttackLogRepository
from app.database.repositories.report_repo import ReportRepository
from app.database.repositories.explanation_repo import AIExplanationRepository
from app.database.repositories.route_repo import RouteRepository
from app.database.repositories.notification_repo import NotificationHistoryRepository

__all__ = [
    "BaseRepository",
    "UserRepository",
    "VehicleRepository",
    "VehicleMessageRepository",
    "PredictionRepository",
    "TrustScoreRepository",
    "EmergencyVehicleRepository",
    "AlertRepository",
    "AttackLogRepository",
    "ReportRepository",
    "AIExplanationRepository",
    "RouteRepository",
    "NotificationHistoryRepository",
]
