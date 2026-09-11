import sys
import os
from pathlib import Path

backend_root = Path(__file__).resolve().parent.parent
if str(backend_root) not in sys.path:
    sys.path.insert(0, str(backend_root))

import json
from app.core.logging import logger, setup_logging
from app.services.notification_manager import DEVICE_TOKENS, NOTIFICATION_HISTORY
from app.services.event_listener import VANETEventListener

# Setup logging
setup_logging()

def run_notifications_simulation() -> None:
    logger.info("Starting VANET Real-Time Notification System Simulation...")

    # Seed mock client device token to simulate FCM targets mapping
    DEVICE_TOKENS.append({
        "id": "mock_id_token",
        "user_id": "test_driver_123",
        "token": "MOCK_TOKEN_ANDROID_CLIENT_VANET_ID_99999",
        "platform": "android"
    })
    logger.info("Seeded mock Android device token.")

    listener = VANETEventListener()

    # =========================================================================
    # Case 1: Malicious Vehicle Detected
    # =========================================================================
    logger.info("\n=== CASE 1: ML Malicious Detection Trigger ===")
    listener.on_malicious_detected(
        vehicle_id="V23",
        attack_type="False Position Attack",
        confidence=94.5,
        trust_score=35.0
    )

    # =========================================================================
    # Case 2: Fake Emergency Claim Detected
    # =========================================================================
    logger.info("\n=== CASE 2: Fake Emergency Status Trigger ===")
    listener.on_fake_emergency_detected(
        vehicle_id="V45",
        reason="Authorization token mismatch signature verification failure.",
        trust_reduction=50.0
    )

    # =========================================================================
    # Case 3: Emergency Vehicle Approaching
    # =========================================================================
    logger.info("\n=== CASE 3: Approaching Ambulance Sirens Trigger ===")
    listener.on_emergency_approaching(
        vehicle_type="Ambulance",
        distance_km=3.2,
        direction="Northbound",
        eta_minutes=3.5
    )

    # =========================================================================
    # Case 4: Accident Reported Ahead
    # =========================================================================
    logger.info("\n=== CASE 4: Traffic Accident Zone Report Trigger ===")
    listener.on_accident_reported(
        accident_id="ACC_ZONE_1",
        location_desc="Road A",
        severity="Critical",
        affected_area=150.0
    )

    # =========================================================================
    # Case 5: Trust score decay trigger
    # =========================================================================
    logger.info("\n=== CASE 5: Vehicle Trust Decay Warning Trigger ===")
    listener.on_trust_decayed(
        vehicle_id="V12",
        previous_score=85.0,
        new_score=35.0,
        reason="Repeated message frequency attack logs decay."
    )

    # =========================================================================
    # Case 6: Traffic Congestion Detour Recommendation Trigger
    # =========================================================================
    logger.info("\n=== CASE 6: Congestion Bypass Detour Trigger ===")
    listener.on_congestion_detected(
        road_id="ROAD_A",
        detour_road="ROAD_C"
    )

    # Print notification logs saved in local database records
    print("\n==================================================")
    print("SAVED NOTIFICATIONS HISTORY LOGS")
    print("==================================================")
    for idx, alert in enumerate(NOTIFICATION_HISTORY, 1):
        print(f"{idx}. Type: {alert['notification_type']} | Title: {alert['title']}")
        print(f"   Message: {alert['message']}")
        print(f"   Priority: {alert['priority']} | Status: {'Read' if alert['is_read'] else 'Unread'}")
        print("--------------------------------------------------")
    print("==================================================")
    
    logger.info("Notification System Event Simulation Completed Successfully!")

if __name__ == "__main__":
    run_notifications_simulation()
