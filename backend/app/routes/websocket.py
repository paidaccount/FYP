from fastapi import APIRouter, WebSocket, WebSocketDisconnect
from typing import List
from app.core.logging import logger

router = APIRouter()

# Active connections list
active_connections: List[WebSocket] = []

@router.websocket("/live")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    active_connections.append(websocket)
    logger.info(f"WebSocket client connected. Total: {len(active_connections)}")
    try:
        while True:
            # Keep connection alive by receiving messages
            data = await websocket.receive_text()
            # Echo or process if needed
            await websocket.send_text(f"Received telemetry sync acknowledgment: {data}")
    except WebSocketDisconnect:
        active_connections.remove(websocket)
        logger.info(f"WebSocket client disconnected. Total: {len(active_connections)}")
    except Exception as e:
        if websocket in active_connections:
            active_connections.remove(websocket)
        logger.error(f"WebSocket connection error: {str(e)}")

async def broadcast_update(payload: dict):
    """Broadcasts vehicle updates to all active listeners."""
    for connection in list(active_connections):
        try:
            await connection.send_json(payload)
        except Exception:
            # Clean dead connections
            if connection in active_connections:
                active_connections.remove(connection)
