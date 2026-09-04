from app.database.models.prediction import Prediction
from app.database.repositories.base import BaseRepository

class PredictionRepository(BaseRepository[Prediction]):
    def __init__(self):
        super().__init__(Prediction)
