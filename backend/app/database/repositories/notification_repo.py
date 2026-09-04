from app.database.models.notification import NotificationHistory
from app.database.repositories.base import BaseRepository

class NotificationHistoryRepository(BaseRepository[NotificationHistory]):
    def __init__(self):
        super().__init__(NotificationHistory)
