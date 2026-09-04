import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.repositories.notification_repo import NotificationHistoryRepository
from app.schemas.notification import NotificationHistoryCreate
from app.database.models.notification import NotificationHistory

class NotificationService:
    """
    Coordinates real-time push notification distributions via FCM,
    and notification delivery audit logging.
    """
    def __init__(self, notification_repo: NotificationHistoryRepository):
        self.notification_repo = notification_repo

    async def log_notification(
        self, 
        db: AsyncSession, 
        notification_in: NotificationHistoryCreate
    ) -> NotificationHistory:
        return await self.notification_repo.create(db, obj_in=notification_in)
