import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.repositories.route_repo import RouteRepository
from app.schemas.route import RouteCreate
from app.database.models.route import Route

class RouteService:
    """
    Coordinates waypoint updates, spatial routing coordinates checking,
    and A* traffic weight maps calculations.
    """
    def __init__(self, route_repo: RouteRepository):
        self.route_repo = route_repo

    async def save_route(self, db: AsyncSession, route_in: RouteCreate) -> Route:
        return await self.route_repo.create(db, obj_in=route_in)
