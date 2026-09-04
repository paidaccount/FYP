from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Dict, Any

router = APIRouter()

class UserLoginSchema(BaseModel):
    username: str
    password: str

class UserRegisterSchema(BaseModel):
    username: str
    email: EmailStr
    password: str
    role: str = "DRIVER"

@router.post("/login")
def login(payload: UserLoginSchema):
    # Standard dummy credential verification
    if payload.username == "admin" and payload.password == "securepassword123":
        return {
            "access_token": "MOCK_JWT_ACCESS_TOKEN_FOR_VANET_ADMIN_FLOW_12345",
            "token_type": "bearer",
            "role": "ADMIN"
        }
    elif payload.username == "driver" and payload.password == "driverpass":
        return {
            "access_token": "MOCK_JWT_ACCESS_TOKEN_FOR_VANET_DRIVER_FLOW_67890",
            "token_type": "bearer",
            "role": "DRIVER"
        }
    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid username or password credentials.")

@router.post("/register", status_code=status.HTTP_201_CREATED)
def register(payload: UserRegisterSchema):
    return {
        "message": "User account registered successfully.",
        "user": {
            "username": payload.username,
            "email": payload.email,
            "role": payload.role
        }
    }
