from app.database.models.emergency import EmergencyVehicle
from app.database.repositories.base import BaseRepository

class EmergencyVehicleRepository(BaseRepository[EmergencyVehicle]):
    def __init__(self):
        super().__init__(EmergencyVehicle)
