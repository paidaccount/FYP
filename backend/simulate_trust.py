import os
import json
from app.core.logging import logger, setup_logging
from app.services.trust_engine import TrustEngine
from app.services.visualization import TrustVisualizer

# Configure logging
setup_logging()

def run_simulation() -> None:
    logger.info("Starting Dynamic Trust Management Engine Simulation...")
    
    engine = TrustEngine()
    visualizer = TrustVisualizer()

    # Active vehicle IDs representing our 4 test scenarios
    vehicles = {
        "VEH_CASE_1_NORMAL": {"label": "Normal Vehicle Simulation", "attack_profile": []},
        "VEH_CASE_2_SINGLE_ATTACK": {"label": "Single Anomaly Simulation", "attack_profile": ["speed_anomaly"]},
        "VEH_CASE_3_REPEATED_ATTACK": {"label": "Persistent Attack Simulation", "attack_profile": ["position_anomaly", "position_anomaly", "position_anomaly"]},
        "VEH_CASE_4_RECOVERY": {"label": "Malicious Recovery Simulation", "attack_profile": ["DoS", "NONE", "NONE", "NONE"]}
    }

    # Clean previous JSON logs in trust_history directory to avoid state carryover
    history_dir = engine.history_manager.history_dir
    for file_name in os.listdir(history_dir):
        if file_name.endswith(".json"):
            os.remove(os.path.join(history_dir, file_name))
    logger.info("Cleared previous trust logs.")

    total_epochs = 5
    simulation_results = {}

    # Run Simulation loops across epochs
    for epoch in range(1, total_epochs + 1):
        logger.info(f"\n--- Running Simulation Epoch {epoch} ---")

        for veh_id, config in vehicles.items():
            # Resolve attack state for this epoch
            attack_profile = config["attack_profile"]
            
            # Default state is normal behavior
            prediction = 0
            attack_type = "NONE"
            xai_lime = {}
            features = {
                "speed_anomaly_score": 0.0,
                "position_anomaly_score": 0.0,
                "GPS_consistency": 0.0,
                "message_frequency_anomaly": 0.0,
                "communication_behavior_score": 0.0
            }

            # Check if this vehicle is scheduled to attack in the current epoch index
            profile_idx = epoch - 1
            if profile_idx < len(attack_profile):
                epoch_attack = attack_profile[profile_idx]
                if epoch_attack != "NONE":
                    prediction = 1
                    attack_type = epoch_attack
                    
                    if epoch_attack == "speed_anomaly":
                        features["speed_anomaly_score"] = 4.5
                        xai_lime = {"speed_anomaly_score": 0.45}
                    elif epoch_attack == "position_anomaly":
                        features["position_anomaly_score"] = 5.2
                        features["GPS_consistency"] = 3.5
                        xai_lime = {"position_anomaly_score": 0.55}
                    elif epoch_attack == "DoS":
                        features["message_frequency_anomaly"] = 1.0
                        features["communication_behavior_score"] = 6.0
                        xai_lime = {"message_frequency_anomaly": 0.60}

            # Process event in Trust Engine
            db_record = engine.process_telemetry_event(
                vehicle_id=veh_id,
                prediction=prediction,
                attack_type=attack_type,
                xai_lime_values=xai_lime,
                message_features=features
            )

            # Store the final composite score progression
            if veh_id not in simulation_results:
                simulation_results[veh_id] = []
            simulation_results[veh_id].append(db_record["current_score"])

    # 1. Output simulation summary logs
    print("\n==================================================")
    print("SIMULATION SUMMARY RESULTS (Trust Score Timelines)")
    print("==================================================")
    for veh_id, scores in simulation_results.items():
        print(f"Vehicle: {veh_id} ({vehicles[veh_id]['label']})")
        print(f"  Score Progression: {scores}")
        # Resolve final status
        history = engine.history_manager.load_history(veh_id)
        final_score = scores[-1]
        print(f"  Final Score: {final_score} | Status: {engine.updater.resolve_status(final_score)}")
        print("--------------------------------------------------")

    # 2. Render individual timeline plots
    logger.info("Generating individual trust timeline charts...")
    for veh_id, scores in simulation_results.items():
        visualizer.plot_trust_timeline(veh_id, scores)

    # 3. Generate fleet rankings details
    rankings = []
    scores_list = []
    for veh_id, scores in simulation_results.items():
        final_score = scores[-1]
        scores_list.append(final_score)
        history = engine.history_manager.load_history(veh_id)
        
        # Calculate attack count
        attack_count = sum(1 for p in history["prediction_history"] if p == 1)

        rankings.append({
            "vehicle_id": veh_id,
            "trust_score": final_score,
            "trust_status": engine.updater.resolve_status(final_score),
            "attack_count": attack_count
        })

    # Sort rankings: highest trust score first
    rankings.sort(key=lambda x: x["trust_score"], reverse=True)

    print("\n==================================================")
    print("FLEET SECURITY TRUST RANKINGS")
    print("==================================================")
    for idx, r in enumerate(rankings, 1):
        print(f"{idx}. Vehicle: {r['vehicle_id']} | Score: {r['trust_score']} | Status: {r['trust_status']} | Attack Count: {r['attack_count']}")
    print("==================================================")

    # Save rankings list to a JSON summary file
    rankings_out = visualizer.plot_dir / "trust_rankings.json"
    with open(rankings_out, "w") as f:
        json.dump(rankings, f, indent=4)

    # 4. Render fleet visual graphics
    logger.info("Generating rankings and distribution plots...")
    visualizer.plot_vehicle_rankings(rankings)
    visualizer.plot_trust_distribution(scores_list)

    logger.info(f"Trust visual charts exported to: {visualizer.plot_dir}")
    logger.info("Trust Management Engine Simulation Completed Successfully!")

if __name__ == "__main__":
    run_simulation()
