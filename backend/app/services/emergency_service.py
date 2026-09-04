import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.repositories.emergency_repo import EmergencyVehicleRepository
from app.schemas.emergency import EmergencyVehicleCreate
from app.database.models.emergency import EmergencyVehicle

class EmergencyService:
    """
    Coordinates Emergency responder status clearance audits
    and preemption authentication tokens checking.
    """
    def __init__(self, emergency_repo: EmergencyVehicleRepository):
        self.emergency_repo = emergency_repo

    async def create_profile(
        self, 
        db: AsyncSession, 
        profile_in: EmergencyVehicleCreate
    ) -> EmergencyVehicle:
        return await self.emergency_repo.create(db, obj_in=profile_in)
