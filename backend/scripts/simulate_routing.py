import sys
import os
from pathlib import Path

backend_root = Path(__file__).resolve().parent.parent
if str(backend_root) not in sys.path:
    sys.path.insert(0, str(backend_root))

import json
from app.core.logging import logger, setup_logging
from app.services.routing.route_optimizer import RouteOptimizer
from app.services.routing.visualization import RouteVisualizer

# Configure logging
setup_logging()

def run_routing_simulation() -> None:
    logger.info("Starting VANET Intelligent Route Recommendation Simulation...")

    optimizer = RouteOptimizer()
    visualizer = RouteVisualizer()

    # Define route query points
    src, dest = "A", "F"
    vehicle_id = "AMB_101"

    # =========================================================================
    # CASE 1: Normal Traffic Conditions
    # =========================================================================
    logger.info("\n=== CASE 1: Normal Traffic Conditions Route Query ===")
    res_normal = optimizer.optimize_route(vehicle_id, src, dest, accident_roads=[])
    
    print("--------------------------------------------------")
    print(f"CASE 1 RESULT: {res_normal['reason']}")
    print(f"Recommended Path: {' -> '.join(res_normal['recommended_route'])}")
    print(f"Alternative Path: {' -> '.join(res_normal['alternative_route'])}")
    print(f"ETA: {res_normal['eta']} minutes")
    print("--------------------------------------------------")

    # Export graph plot for normal state
    visualizer.plot_road_network(optimizer.graph, "case1_normal_route.png", res_normal["recommended_route"])


    # =========================================================================
    # CASE 2: Accident blocks shortest route
    # =========================================================================
    logger.info("\n=== CASE 2: Accident blocks ROAD_BC ===")
    # Block ROAD_BC where accident occurs
    res_accident = optimizer.optimize_route(vehicle_id, src, dest, accident_roads=["ROAD_BC"])

    print("--------------------------------------------------")
    print(f"CASE 2 RESULT: {res_accident['reason']}")
    print(f"Recommended Path: {' -> '.join(res_accident['recommended_route'])}")
    print(f"Alternative Path: {' -> '.join(res_accident['alternative_route'])}")
    print(f"ETA: {res_accident['eta']} minutes")
    print("--------------------------------------------------")

    # Export graph plot for accident detour state
    # Apply accident temporary status to map drawing representation
    optimizer.accident_analyzer.register_accident_on_road(optimizer.graph, "ROAD_BC")
    visualizer.plot_road_network(optimizer.graph, "case2_detour_route.png", res_accident["recommended_route"])
    optimizer.accident_analyzer.clear_accident_on_road(optimizer.graph, "ROAD_BC") # Clear map status


    # =========================================================================
    # CASE 3: Heavy Traffic Congestion Bypass
    # =========================================================================
    logger.info("\n=== CASE 3: Heavy Congestion Bypass ===")
    # Set heavy congestion score (80%) on ROAD_BC, leaving ROAD_DC light (15%)
    # This is already set in builder. Edge BC density is 80.
    res_heavy = optimizer.optimize_route(vehicle_id, src, dest, accident_roads=[])

    print("--------------------------------------------------")
    print(f"CASE 3 RESULT: {res_heavy['reason']}")
    print(f"Recommended Path: {' -> '.join(res_heavy['recommended_route'])}")
    print(f"Alternative Path: {' -> '.join(res_heavy['alternative_route'])}")
    print(f"ETA: {res_heavy['eta']} minutes")
    print("--------------------------------------------------")

    # Export graph plot for heavy traffic state
    visualizer.plot_road_network(optimizer.graph, "case3_congestion_route.png", res_heavy["recommended_route"])


    # =========================================================================
    # CASE 4: Pathfinders Comparison (Dijkstra vs A*)
    # =========================================================================
    logger.info("\n=== CASE 4: Algorithm Benchmarking comparison ===")
    comp = res_normal["comparison"]
    d_stats = comp["dijkstra"]
    a_stats = comp["astar"]

    print("--------------------------------------------------")
    print("ALGORITHM COMPARISON:")
    print(f"Dijkstra's Pathfinder:")
    print(f"  Path Found: {' -> '.join(d_stats['path'])}")
    print(f"  Dynamic Cost Score: {d_stats['cost']:.2f}")
    print(f"  Execution Time: {d_stats['time_ns']} ns")
    print(f"  Memory Footprint: {d_stats['memory_bytes']} bytes")
    print(f"A* Pathfinder:")
    print(f"  Path Found: {' -> '.join(a_stats['path'])}")
    print(f"  Dynamic Cost Score: {a_stats['cost']:.2f}")
    print(f"  Execution Time: {a_stats['time_ns']} ns")
    print(f"  Memory Footprint: {a_stats['memory_bytes']} bytes")
    print("--------------------------------------------------")

    # Export comparison benchmarking plot
    visualizer.plot_algorithm_comparison(d_stats["time_ns"], a_stats["time_ns"])

    logger.info(f"Routing visual charts exported to: {visualizer.plot_dir}")
    logger.info("VANET Intelligent Route Recommendation Simulation Completed Successfully!")

if __name__ == "__main__":
    run_routing_simulation()
