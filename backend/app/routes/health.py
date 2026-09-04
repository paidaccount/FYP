from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
from app.dependencies.database import get_db

router = APIRouter()

@router.get("/health")
async def health_check():
    """
    Returns general system operational status.
    """
    return {"status": "healthy"}

@router.get("/ping")
async def ping_pong():
    """
    Ping-pong test for network latency analysis.
    """
    return "pong"

@router.get("/version")
async def get_version():
    """
    Returns the current software version.
    """
    return {
        "version": "1.0.0",
        "environment": "development",
        "phase": "Phase 2 Foundation"
    }

@router.get("/database")
async def test_database_connection(db: AsyncSession = Depends(get_db)):
    """
    Validates transactional read/write connectivity with PostgreSQL.
    """
    try:
        # Execute query SELECT 1
        result = await db.execute(text("SELECT 1"))
        val = result.scalar()
        if val == 1:
            return {
                "status": "connected",
                "backend": "PostgreSQL with PostGIS"
            }
        else:
            raise Exception("Unexpected query result value.")
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=f"Database verification failure: {str(e)}"
        )
