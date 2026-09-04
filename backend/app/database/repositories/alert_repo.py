from app.database.models.alert import Alert
from app.database.repositories.base import BaseRepository

class AlertRepository(BaseRepository[Alert]):
    def __init__(self):
        super().__init__(Alert)
