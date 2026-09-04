print("EXECUTING MAIN.PY!!!")
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware

from app.core.config import settings
from app.core.logging import setup_logging
from app.core.exceptions import (
    EntityNotFoundException,
    AuthenticationException,
    AuthorizationException,
    DatabaseException,
    ValidationException,
    entity_not_found_handler,
    authentication_exception_handler,
    authorization_exception_handler,
    database_exception_handler,
    validation_exception_handler,
    general_exception_handler
)
from app.middleware.request_logger import RequestLoggerMiddleware
from app.middleware.rate_limiter import RateLimiterMiddleware
from app.routes.api import api_router

# Initialize system loggers
setup_logging()

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Explainable AI-Based Misbehavior Detection and Trust Management System for VANET with Emergency Vehicle Priority Management",
    version="1.0.0",
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc"
)

# Standard Middlewares
app.add_middleware(
    CORSMiddleware,
    allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(
    TrustedHostMiddleware, 
    allowed_hosts=["*"]  # Configure strict host validation lists in production settings
)

# Custom Middlewares
app.add_middleware(RequestLoggerMiddleware)
app.add_middleware(RateLimiterMiddleware, rate_limit=100, window_seconds=60)

# Register Custom Exception Handlers
app.add_exception_handler(EntityNotFoundException, entity_not_found_handler)
app.add_exception_handler(AuthenticationException, authentication_exception_handler)
app.add_exception_handler(AuthorizationException, authorization_exception_handler)
app.add_exception_handler(DatabaseException, database_exception_handler)
app.add_exception_handler(ValidationException, validation_exception_handler)
app.add_exception_handler(Exception, general_exception_handler)

# Include APIs
app.include_router(api_router, prefix=settings.API_V1_STR)

# Include WebSockets
from app.routes.websocket import router as ws_router
app.include_router(ws_router, prefix="/ws")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
