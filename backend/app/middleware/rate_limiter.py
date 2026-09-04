import time
from fastapi import Request, Response, status
from starlette.middleware.base import BaseHTTPMiddleware
from redis.asyncio import Redis, from_url
from app.core.config import settings
from app.core.logging import logger

class RateLimiterMiddleware(BaseHTTPMiddleware):
    """
    Asynchronous Redis-based rate limiting middleware.
    Utilizes a sliding window counter to throttle clients by IP.
    """
    def __init__(
        self, 
        app, 
        redis_url: str = settings.REDIS_URL, 
        rate_limit: int = 100, 
        window_seconds: int = 60
    ):
        super().__init__(app)
        self.redis_url = redis_url
        self.rate_limit = rate_limit
        self.window_seconds = window_seconds
        self.redis_client = None

    async def _get_redis(self) -> Redis:
        if self.redis_client is None:
            try:
                self.redis_client = from_url(
                    self.redis_url, 
                    encoding="utf-8", 
                    decode_responses=True
                )
            except Exception as e:
                logger.error(f"Redis connection initialization failed: {str(e)}")
        return self.redis_client

    async def dispatch(self, request: Request, call_next) -> Response:
        # Exclude telemetry health points from rate limiting
        if request.url.path in ["/", "/health", "/ping", "/version", "/database", "/docs", "/openapi.json"]:
            return await call_next(request)

        client_ip = request.client.host if request.client else "unknown"
        redis = await self._get_redis()

        if redis:
            try:
                key = f"rate:{client_ip}:{request.url.path}"
                now = time.time()
                clear_before = now - self.window_seconds
                
                # Execute transaction pipeline for atomicity
                async with redis.pipeline(transaction=True) as pipe:
                    pipe.zremrangebyscore(key, 0, clear_before)
                    pipe.zcard(key)
                    pipe.zadd(key, {f"{now}": now})
                    pipe.expire(key, self.window_seconds)
                    results = await pipe.execute()
                
                current_hits = results[1]
                if current_hits >= self.rate_limit:
                    logger.warning(f"Rate limit hit: IP {client_ip} on path {request.url.path}")
                    return Response(
                        content="Too Many Requests. Rate limit exceeded.",
                        status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                        media_type="text/plain"
                    )
            except Exception as e:
                # Fail-open strategy to prevent Redis failures from blocking APIs
                logger.error(f"Rate limiting failure (fail-open): {str(e)}")

        return await call_next(request)
