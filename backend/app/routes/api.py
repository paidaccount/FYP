from fastapi import APIRouter
from app.routes.auth import router as auth_router
from app.routes.vehicles import router as vehicles_router
from app.routes.messages import router as messages_router
from app.routes.predictions import router as prediction_router
from app.routes.explanations import router as xai_router
from app.routes.trust import router as trust_router
from app.routes.emergency import router as emergency_router
from app.routes.routing import router as routing_router
from app.routes.reports import router as reports_router
from app.routes.analytics import router as analytics_router
from app.routes.health import router as health_router
from app.routes.alerts import router as alerts_router

api_router = APIRouter()

# Diagnostics
api_router.include_router(health_router, tags=["Health Diagnostics"])

# Core modules
api_router.include_router(auth_router, prefix="/auth", tags=["Authentication"])
api_router.include_router(vehicles_router, prefix="/vehicles", tags=["Vehicles"])
api_router.include_router(messages_router, prefix="/messages", tags=["Messages"])
api_router.include_router(prediction_router, prefix="/prediction", tags=["Predictions"])
api_router.include_router(xai_router, prefix="/xai", tags=["Explainable AI"])
api_router.include_router(trust_router, prefix="/trust", tags=["Trust Management"])
api_router.include_router(emergency_router, prefix="/emergency", tags=["Emergency Priority"])
api_router.include_router(routing_router, tags=["Routing & Accidents"])
api_router.include_router(routing_router, prefix="/routing", tags=["Routing & Accidents"])
api_router.include_router(reports_router, prefix="/reports", tags=["Reports"])
api_router.include_router(analytics_router, prefix="/analytics", tags=["Analytics"])
api_router.include_router(alerts_router, prefix="/notifications", tags=["Notifications"])
