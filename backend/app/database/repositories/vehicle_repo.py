from typing import Optional
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.models.vehicle import Vehicle
from app.database.repositories.base import BaseRepository

class VehicleRepository(BaseRepository[Vehicle]):
    def __init__(self):
        super().__init__(Vehicle)

    async def get_by_license_plate(self, db: AsyncSession, license_plate: str) -> Optional[Vehicle]:
        """
        Retrieves vehicle metadata by license plate lookup.
        """
        query = select(Vehicle).where(Vehicle.license_plate == license_plate)
        result = await db.execute(query)
        return result.scalars().first()
