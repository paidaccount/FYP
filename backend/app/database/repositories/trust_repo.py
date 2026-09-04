from app.database.models.trust import TrustScore
from app.database.repositories.base import BaseRepository

class TrustScoreRepository(BaseRepository[TrustScore]):
    def __init__(self):
        super().__init__(TrustScore)
