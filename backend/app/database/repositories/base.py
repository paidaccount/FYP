from typing import Any, Dict, Generic, List, Optional, Type, TypeVar
from sqlalchemy import select, delete, or_
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.db import Base

ModelType = TypeVar("ModelType", bound=Base)

class BaseRepository(Generic[ModelType]):
    """
    Generic Repository Pattern implementation offering:
    - fetch by ID
    - count and paginate listing
    - conditional filters and case-insensitive searching
    - asynchronous updates and deletion contexts
    """
    def __init__(self, model: Type[ModelType]):
        self.model = model

    async def get(self, db: AsyncSession, id: Any) -> Optional[ModelType]:
        query = select(self.model).where(self.model.id == id)
        result = await db.execute(query)
        return result.scalars().first()

    async def get_multi(
        self,
        db: AsyncSession,
        *,
        skip: int = 0,
        limit: int = 100,
        filters: Optional[Dict[str, Any]] = None,
        search_query: Optional[str] = None,
        search_fields: Optional[List[str]] = None
    ) -> List[ModelType]:
        query = select(self.model)

        # Apply exact match filters
        if filters:
            for field, value in filters.items():
                if hasattr(self.model, field):
                    query = query.where(getattr(self.model, field) == value)

        # Apply case-insensitive OR search filters
        if search_query and search_fields:
            clauses = []
            for field in search_fields:
                if hasattr(self.model, field):
                    clauses.append(getattr(self.model, field).ilike(f"%{search_query}%"))
            if clauses:
                query = query.where(or_(*clauses))

        # Order by creation date if available
        if hasattr(self.model, "created_at"):
            query = query.order_by(self.model.created_at.desc())

        query = query.offset(skip).limit(limit)
        result = await db.execute(query)
        return list(result.scalars().all())

    async def create(self, db: AsyncSession, *, obj_in: Any) -> ModelType:
        if isinstance(obj_in, dict):
            db_obj = self.model(**obj_in)
        else:
            db_obj = self.model(**obj_in.model_dump())
        
        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def update(self, db: AsyncSession, *, db_obj: ModelType, obj_in: Any) -> ModelType:
        if isinstance(obj_in, dict):
            update_data = obj_in
        else:
            update_data = obj_in.model_dump(exclude_unset=True)

        for field in update_data:
            if hasattr(db_obj, field):
                setattr(db_obj, field, update_data[field])

        db.add(db_obj)
        await db.commit()
        await db.refresh(db_obj)
        return db_obj

    async def remove(self, db: AsyncSession, *, id: Any) -> Optional[ModelType]:
        db_obj = await self.get(db, id)
        if db_obj:
            query = delete(self.model).where(self.model.id == id)
            await db.execute(query)
            await db.commit()
        return db_obj
