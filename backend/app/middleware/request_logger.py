import time
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware
from app.core.logging import logger

class RequestLoggerMiddleware(BaseHTTPMiddleware):
    """
    Middleware that intercept HTTP requests to track execution latency
    and log incoming traffic parameters.
    """
    async def dispatch(self, request: Request, call_next):
        start_time = time.time()
        
        # Log basic request parameters
        logger.info(f"Incoming: {request.method} {request.url.path} from client {request.client.host if request.client else 'unknown'}")
        
        try:
            response = await call_next(request)
        except Exception as e:
            # Latency logging in case of failure
            duration = (time.time() - start_time) * 1000
            logger.error(f"Request failed: {request.method} {request.url.path} after {duration:.2f}ms. Exception: {str(e)}")
            raise e

        duration = (time.time() - start_time) * 1000
        
        # Log response statistics
        logger.info(f"Completed: {request.method} {request.url.path} - Status: {response.status_code} - Duration: {duration:.2f}ms")
        
        # Inject performance telemetry headers
        response.headers["X-Response-Time-Ms"] = f"{duration:.2f}"
        return response
