import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.repositories.report_repo import ReportRepository
from app.schemas.report import ReportCreate
from app.database.models.report import Report

class ReportService:
    """
    Coordinates citizen road reports, accident warnings, 
    and spatial hazard indexes queries.
    """
    def __init__(self, report_repo: ReportRepository):
        self.report_repo = report_repo

    async def submit_report(self, db: AsyncSession, report_in: ReportCreate) -> Report:
        return await self.report_repo.create(db, obj_in=report_in)
