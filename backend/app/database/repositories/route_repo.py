from app.database.models.route import Route
from app.database.repositories.base import BaseRepository

class RouteRepository(BaseRepository[Route]):
    def __init__(self):
        super().__init__(Route)
