from fastapi import Request, status
from fastapi.responses import JSONResponse
from app.core.logging import logger

class VANETException(Exception):
    """Base exception for all system-related operations."""
    def __init__(self, message: str):
        super().__init__(message)
        self.message = message

class EntityNotFoundException(VANETException):
    """Exception raised when an expected database entity is missing."""
    pass

class AuthenticationException(VANETException):
    """Exception raised during login/JWT validation issues."""
    pass

class AuthorizationException(VANETException):
    """Exception raised for insufficient user role privileges."""
    pass

class DatabaseException(VANETException):
    """Exception raised during SQL failures or connection issues."""
    pass

class ValidationException(VANETException):
    """Exception raised for invalid telemetry message schemas or digital signatures."""
    pass

# Global Exception Handlers mapping custom exceptions to HTTP Responses
async def entity_not_found_handler(request: Request, exc: EntityNotFoundException) -> JSONResponse:
    logger.warning(f"EntityNotFound: {exc.message} on path {request.url.path}")
    return JSONResponse(
        status_code=status.HTTP_404_NOT_FOUND,
        content={"detail": exc.message}
    )

async def authentication_exception_handler(request: Request, exc: AuthenticationException) -> JSONResponse:
    logger.warning(f"Authentication failed: {exc.message} on path {request.url.path}")
    return JSONResponse(
        status_code=status.HTTP_401_UNAUTHORIZED,
        content={"detail": exc.message},
        headers={"WWW-Authenticate": "Bearer"}
    )

async def authorization_exception_handler(request: Request, exc: AuthorizationException) -> JSONResponse:
    logger.warning(f"Authorization denied: {exc.message} on path {request.url.path}")
    return JSONResponse(
        status_code=status.HTTP_403_FORBIDDEN,
        content={"detail": exc.message}
    )

async def database_exception_handler(request: Request, exc: DatabaseException) -> JSONResponse:
    logger.error(f"Database error encountered: {exc.message} on path {request.url.path}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "A secure database error occurred. Action logged."}
    )

async def validation_exception_handler(request: Request, exc: ValidationException) -> JSONResponse:
    logger.warning(f"Validation failure: {exc.message} on path {request.url.path}")
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"detail": exc.message}
    )

async def general_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    logger.error(f"Unhandled system error: {str(exc)} on path {request.url.path}", exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "Internal Server Error"}
    )
