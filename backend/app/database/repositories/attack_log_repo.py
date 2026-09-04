from app.database.models.attack_log import AttackLog
from app.database.repositories.base import BaseRepository

class AttackLogRepository(BaseRepository[AttackLog]):
    def __init__(self):
        super().__init__(AttackLog)
