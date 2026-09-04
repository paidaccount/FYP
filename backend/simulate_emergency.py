import json
from app.core.logging import logger, setup_logging
from app.services.emergency.emergency_detector import EmergencyDetector
from app.services.emergency.accident_manager import AccidentManager
from app.services.emergency.schemas import EmergencyVerificationRequest
from app.services.emergency.visualization import EmergencyVisualizer

# Configure logging
setup_logging()

def run_emergency_simulation() -> None:
    logger.info("Starting Emergency Vehicle Priority Management Simulation...")

    detector = EmergencyDetector()
    accident_manager = AccidentManager()
    visualizer = EmergencyVisualizer()

    # Lists to hold stats for dashboard plotting
    priorities_list = []
    statuses_list = []
    total_claims = 0
    fake_claims = 0

    # =========================================================================
    # CASE 1: Authenticated Ambulance
    # =========================================================================
    logger.info("\n=== CASE 1: Authenticated Ambulance Priority Request ===")
    req_ambulance = EmergencyVerificationRequest(
        vehicle_id="AMB_101",
        emergency_type="Ambulance",
        authorization_token="AUTH_EMERGENCY_AMBULANCE_AMB_101",
        digital_identity="DIGITAL_SIG_AMBULANCE_VALID_KEY_123"
    )
    res_amb = detector.process_emergency_request(
        auth_request=req_ambulance,
        trust_score=95.0, # High trust
        ml_prediction=0,   # Normal behavior
        attack_history=[],
        comm_anomaly_detected=False,
        distance_km=3.5,
        traffic_condition="Medium",
        road_availability=True
    )
    total_claims += 1
    priorities_list.append(res_amb["priority_level"])
    statuses_list.append("Dispatched")

    print("--------------------------------------------------")
    print(f"CASE 1 RESULT: {res_amb['verification_result']}")
    print(f"Status: {res_amb['status']}")
    print(f"Priority Level: {res_amb['priority_level']} | Score: {res_amb.get('priority_score')}")
    print(f"ETA: {res_amb['eta_minutes']} minutes")
    print(f"Alert Dispatched: {json.dumps(res_amb.get('alert'), indent=2)}")
    print("--------------------------------------------------")


    # =========================================================================
    # CASE 2: Fake Ambulance Claim
    # =========================================================================
    logger.info("\n=== CASE 2: Fake Ambulance Claim Reject Request ===")
    req_fake = EmergencyVerificationRequest(
        vehicle_id="AMB_999_MALICIOUS",
        emergency_type="Ambulance",
        authorization_token="AUTH_EMERGENCY_AMBULANCE_FAKE_TOKEN", # Token mismatch
        digital_identity="BAD_KEY"
    )
    res_fake = detector.process_emergency_request(
        auth_request=req_fake,
        trust_score=85.0,
        ml_prediction=0,
        attack_history=[],
        comm_anomaly_detected=False,
        distance_km=1.2,
        traffic_condition="Heavy",
        road_availability=True
    )
    total_claims += 1
    fake_claims += 1
    priorities_list.append(res_fake["priority_level"])
    statuses_list.append("Inactive")

    print("--------------------------------------------------")
    print(f"CASE 2 RESULT: {res_fake['verification_result']}")
    print(f"Status: {res_fake['status']}")
    print(f"Priority Level: {res_fake['priority_level']}")
    print(f"Penalized Trust Score: {res_fake.get('penalized_trust')}")
    print(f"Security Alert Triggered: {json.dumps(res_fake.get('alert'), indent=2)}")
    print("--------------------------------------------------")


    # =========================================================================
    # CASE 3: Police Vehicle Approaching Accident Zone
    # =========================================================================
    logger.info("\n=== CASE 3: Accident Response simulation ===")
    # 1. Report Accident
    accident_loc = {"x": 500.0, "y": 500.0}
    accident = accident_manager.report_accident(
        accident_id="ACC_ZONE_1",
        location=accident_loc,
        severity="Critical",
        affected_area=150.0 # 150 meters
    )

    # 2. Identify surrounding vehicles (e.g. standard vehicle veh_301 is nearby)
    vehicles_locations = {
        "veh_301": {"x": 510.0, "y": 490.0}, # Inside zone
        "veh_302": {"x": 900.0, "y": 200.0}  # Outside zone
    }
    nearby_vehs = accident_manager.identify_nearby_vehicles("ACC_ZONE_1", vehicles_locations)
    print(f"Accident logged at coordinates {accident_loc}. Nearby standard vehicles warned: {nearby_vehs}")

    # 3. Process approaching police request
    req_police = EmergencyVerificationRequest(
        vehicle_id="POL_202",
        emergency_type="Police",
        authorization_token="AUTH_EMERGENCY_POLICE_POL_202",
        digital_identity="DIGITAL_SIG_POLICE_VALID_KEY_456"
    )
    res_pol = detector.process_emergency_request(
        auth_request=req_police,
        trust_score=90.0,
        ml_prediction=0,
        attack_history=[],
        comm_anomaly_detected=False,
        distance_km=5.0,
        traffic_condition="Heavy",
        road_availability=True,
        accident_severity="Critical"
    )
    total_claims += 1
    priorities_list.append(res_pol["priority_level"])
    statuses_list.append("Dispatched")

    print("--------------------------------------------------")
    print(f"CASE 3 RESULT: {res_pol['verification_result']}")
    print(f"Approaching vehicle: {req_police.vehicle_id}")
    print(f"Priority level granted (Accident response): {res_pol['priority_level']} | Score: {res_pol.get('priority_score')}")
    print(f"ETA to accident zone: {res_pol['eta_minutes']} minutes")
    print(f"Warned surrounding vehicles: {nearby_vehs}")
    print("--------------------------------------------------")


    # =========================================================================
    # CASE 4: Low Trust Emergency Vehicle
    # =========================================================================
    logger.info("\n=== CASE 4: Low-Trust Emergency Vehicle Request ===")
    req_rescue = EmergencyVerificationRequest(
        vehicle_id="RSC_303",
        emergency_type="Rescue",
        authorization_token="AUTH_EMERGENCY_RESCUE_RSC_303",
        digital_identity="DIGITAL_SIG_RESCUE_VALID_KEY_789"
    )
    res_rescue = detector.process_emergency_request(
        auth_request=req_rescue,
        trust_score=35.0, # Low trust (< 40.0) -> triggers verification failure
        ml_prediction=0,
        attack_history=[],
        comm_anomaly_detected=False,
        distance_km=2.0,
        traffic_condition="Light",
        road_availability=True
    )
    total_claims += 1
    fake_claims += 1
    priorities_list.append(res_rescue["priority_level"])
    statuses_list.append("Active")

    print("--------------------------------------------------")
    print(f"CASE 4 RESULT: {res_rescue['verification_result']}")
    print(f"Status: {res_rescue['status']}")
    print(f"Priority Level: {res_rescue['priority_level']}")
    print(f"System Response: {res_rescue['reason']}")
    print("--------------------------------------------------")

    # Generate visual dashboards
    logger.info("Generating dashboard and priority visuals...")
    visualizer.plot_priority_distribution(priorities_list)
    visualizer.plot_emergency_statuses(statuses_list)
    visualizer.plot_fake_statistics(total_claims, fake_claims)
    
    logger.info(f"Priority dashboards exported to: {visualizer.plot_dir}")
    logger.info("Emergency vehicle priority simulation completed successfully!")

if __name__ == "__main__":
    run_emergency_simulation()
