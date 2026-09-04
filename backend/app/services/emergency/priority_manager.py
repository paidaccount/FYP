from app.services.emergency.emergency_config import (
    WEIGHT_VEHICLE_TYPE,
    WEIGHT_TRUST_SCORE,
    WEIGHT_ACCIDENT_SEVERITY,
    WEIGHT_TRAFFIC_CONDITIONS
)
from app.services.emergency.schemas import PriorityCalculationRequest, PriorityCalculationResponse

class PriorityManager:
    """
    Computes priority levels and prioritization coefficients for emergency vehicles
    based on vehicle type, trust standings, traffic conditions, and accident severities.
    """
    def calculate_priority(self, request: PriorityCalculationRequest) -> PriorityCalculationResponse:
        # 1. Resolve vehicle type score
        v_type = request.vehicle_type.lower()
        if "ambulance" in v_type:
            type_score = 100.0
        elif "fire" in v_type:
            type_score = 90.0
        elif "police" in v_type:
            type_score = 80.0
        elif "rescue" in v_type:
            type_score = 70.0
        else:
            type_score = 50.0

        # 2. Resolve trust score component (direct mapping 0-100)
        trust_score = max(0.0, min(100.0, request.trust_score))

        # 3. Resolve accident severity score
        acc_sev = request.accident_severity.upper() if request.accident_severity else "NONE"
        if acc_sev == "CRITICAL":
            acc_score = 100.0
        elif acc_sev == "HIGH":
            acc_score = 80.0
        elif acc_sev == "MEDIUM":
            acc_score = 60.0
        elif acc_sev == "LOW":
            acc_score = 40.0
        else:
            acc_score = 0.0

        # 4. Resolve traffic condition score
        traf_cond = request.traffic_condition.upper()
        if traf_cond == "HEAVY":
            traffic_score = 100.0
        elif traf_cond == "MEDIUM":
            traffic_score = 70.0
        else:
            traffic_score = 40.0

        # Compute composite priority score (0-100)
        composite_score = (
            (type_score * WEIGHT_VEHICLE_TYPE) +
            (trust_score * WEIGHT_TRUST_SCORE) +
            (acc_score * WEIGHT_ACCIDENT_SEVERITY) +
            (traffic_score * WEIGHT_TRAFFIC_CONDITIONS)
        )

        # Scale down priority score if road availability is false or trust is low
        if not request.road_availability:
            composite_score *= 0.7 # 30% reduction if road blocked
        if trust_score < 40.0:
            composite_score *= 0.5 # 50% penalty for untrusted vehicles

        # Map score to priority level
        if composite_score >= 85.0:
            level = "Critical"
        elif composite_score >= 60.0:
            level = "High"
        elif composite_score >= 35.0:
            level = "Medium"
        else:
            level = "Low"

        # Special overrides: any critical accident responds with Critical priority
        if acc_sev == "CRITICAL" and trust_score >= 40.0:
            level = "Critical"

        return PriorityCalculationResponse(
            vehicle_id=request.vehicle_id,
            priority_level=level,
            priority_score=round(composite_score, 2)
        )
