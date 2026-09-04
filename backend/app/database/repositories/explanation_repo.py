from app.database.models.explanation import AIExplanation
from app.database.repositories.base import BaseRepository

class AIExplanationRepository(BaseRepository[AIExplanation]):
    def __init__(self):
        super().__init__(AIExplanation)
