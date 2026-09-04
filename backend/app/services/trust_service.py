import uuid
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.repositories.trust_repo import TrustScoreRepository
from app.schemas.trust import TrustScoreCreate
from app.database.models.trust import TrustScore

class TrustService:
    """
    Coordinates dynamic trust score aggregation, consensus matching,
    and trust decrement logging.
    """
    def __init__(self, trust_repo: TrustScoreRepository):
        self.trust_repo = trust_repo

    async def record_evaluation(
        self, 
        db: AsyncSession, 
        vehicle_id: uuid.UUID, 
        score: float, 
        reason: str
    ) -> TrustScore:
        """
        Creates an audit entry for a vehicle trust score update.
        """
        obj_in = TrustScoreCreate(
            vehicle_id=vehicle_id,
            score=score,
            update_reason=reason
        )
        return await self.trust_repo.create(db, obj_in=obj_in)
