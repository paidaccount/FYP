from app.database.models.message import VehicleMessage
from app.database.repositories.base import BaseRepository

class VehicleMessageRepository(BaseRepository[VehicleMessage]):
    def __init__(self):
        super().__init__(VehicleMessage)
