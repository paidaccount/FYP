from app.database.models.report import Report
from app.database.repositories.base import BaseRepository

class ReportRepository(BaseRepository[Report]):
    def __init__(self):
        super().__init__(Report)
