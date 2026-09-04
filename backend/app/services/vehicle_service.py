import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.repositories.vehicle_repo import VehicleRepository
from app.schemas.vehicle import VehicleCreate, VehicleUpdate
from app.database.models.vehicle import Vehicle
from app.core.exceptions import EntityNotFoundException, ValidationException

class VehicleService:
    """
    Coordinates vehicle profile updates, certification registrations,
    and active status querying.
    """
    def __init__(self, vehicle_repo: VehicleRepository):
        self.vehicle_repo = vehicle_repo

    async def register_vehicle(self, db: AsyncSession, vehicle_in: VehicleCreate) -> Vehicle:
        existing = await self.vehicle_repo.get_by_license_plate(db, vehicle_in.license_plate)
        if existing:
            raise ValidationException(f"License plate '{vehicle_in.license_plate}' already registered.")
        return await self.vehicle_repo.create(db, obj_in=vehicle_in)

    async def get_vehicle(self, db: AsyncSession, vehicle_id: uuid.UUID) -> Vehicle:
        vehicle = await self.vehicle_repo.get(db, vehicle_id)
        if not vehicle:
            raise EntityNotFoundException("Vehicle not found.")
        return vehicle

    async def update_trust(self, db: AsyncSession, vehicle_id: uuid.UUID, trust_score: float) -> Vehicle:
        vehicle = await self.get_vehicle(db, vehicle_id)
        return await self.vehicle_repo.update(db, db_obj=vehicle, obj_in={"trust_score": trust_score})
