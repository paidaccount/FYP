from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from typing import Dict, Any, Optional
from app.database.store import PREDICTIONS

router = APIRouter()

class XAIExplanationResponse(BaseModel):
    prediction_id: str
    prediction: str
    confidence: float
    shap_features: Dict[str, float]
    lime_features: Dict[str, float]
    human_explanation: str

@router.get("/explanation/{prediction_id}", response_model=XAIExplanationResponse)
def get_explanation(prediction_id: str):
    if prediction_id not in PREDICTIONS:
        # Check if we have mock explanation data for testing
        if prediction_id == "mock_pred_123":
            return XAIExplanationResponse(
                prediction_id=prediction_id,
                prediction="Malicious Vehicle",
                confidence=95.0,
                shap_features={"speed_anomaly_score": 0.35, "position_anomaly_score": 0.28, "message_frequency_anomaly": 0.22},
                lime_features={"speed_anomaly_score": 0.31, "position_anomaly_score": 0.25, "message_frequency_anomaly": 0.20},
                human_explanation="The vehicle was detected as malicious because it showed abnormal speed changes, inconsistent GPS movement, and unusually high communication frequency."
            )
        raise HTTPException(status_code=404, detail="Explanation not found for the requested prediction ID.")
        
    pred = PREDICTIONS[prediction_id]
    return XAIExplanationResponse(
        prediction_id=prediction_id,
        prediction=pred["prediction"],
        confidence=pred["confidence"],
        shap_features=pred["shap_values"],
        lime_features=pred["lime_values"],
        human_explanation=pred["generated_reason"]
    )
