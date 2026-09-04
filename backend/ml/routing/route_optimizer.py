import time
import sys
import uuid
from datetime import datetime
from typing import Dict, Any, List, Tuple
import networkx as nx
from app.services.routing.graph_builder import VANETGraphBuilder
from app.services.routing.route_scorer import RouteScorer
from app.services.routing.dijkstra import DijkstraPathfinder
from app.services.routing.astar import AStarPathfinder
from app.services.routing.eta_estimator import ETAEstimator
from app.services.routing.accident_analyzer import AccidentAnalyzer

class RouteOptimizer:
    """
    Orchestration class executing Dijkstra and A* routing models, profiling execution,
    generating alternative routes, and mapping output schemas.
    """
    def __init__(self):
        self.builder = VANETGraphBuilder()
        self.scorer = RouteScorer()
        self.dijkstra = DijkstraPathfinder()
        self.astar = AStarPathfinder()
        self.eta_estimator = ETAEstimator()
        self.accident_analyzer = AccidentAnalyzer()
        self.graph = self.builder.build_default_network()

    def get_alternative_route(self, source: str, destination: str, recommended_path: List[str]) -> List[str]:
        """
        Calculates a secondary backup path by temporarily removing the most critical edge
        of the primary route.
        """
        if len(recommended_path) < 3:
            return recommended_path # No intermediate edge to detour

        # Find the middle edge of the recommended route to remove
        u = recommended_path[len(recommended_path)//2 - 1]
        v = recommended_path[len(recommended_path)//2]
        
        # Clone graph and remove edge
        temp_graph = self.graph.copy()
        if temp_graph.has_edge(u, v):
            temp_graph.remove_edge(u, v)

        # Re-run Dijkstra path finder
        alt_path, _, _ = self.dijkstra.find_route(temp_graph, source, destination)
        return alt_path if alt_path else recommended_path

    def optimize_route(
        self, 
        vehicle_id: str, 
        source: str, 
        destination: str, 
        accident_roads: List[str] = None
    ) -> Dict[str, Any]:
        """
        Executes path calculations, updates blockages, benchmarks algos, and maps
        the final database output schemas.
        """
        # 1. Update graph accident blockages
        if accident_roads:
            for road in accident_roads:
                self.accident_analyzer.register_accident_on_road(self.graph, road)

        # 2. Recalculate edge costs
        self.scorer.apply_costs_to_graph(self.graph)

        # 3. Profile Dijkstra path finder
        t0 = time.perf_counter_ns()
        d_path, d_len, d_cost = self.dijkstra.find_route(self.graph, source, destination)
        d_time = time.perf_counter_ns() - t0

        # 4. Profile A* path finder
        t1 = time.perf_counter_ns()
        a_path, a_len, a_cost = self.astar.find_route(self.graph, source, destination)
        a_time = time.perf_counter_ns() - t1

        # Check for route availability
        if not d_path:
            return {
                "id": str(uuid.uuid4()),
                "vehicle_id": vehicle_id,
                "source": source,
                "destination": destination,
                "recommended_route": [],
                "alternative_route": [],
                "eta": 0.0,
                "reason": "No viable route exists. All connection segments blocked.",
                "timestamp": datetime.utcnow().isoformat(),
                "profiling": {"dijkstra_ns": d_time, "astar_ns": a_time}
            }

        # 5. Estimate travel time
        eta = self.eta_estimator.estimate_route_eta(self.graph, d_path)

        # 6. Retrieve alternative backup route
        alt_path = self.get_alternative_route(source, destination, d_path)

        # 7. Generate reason description
        congested_edges = [self.graph[d_path[i]][d_path[i+1]].get("road_id") for i in range(len(d_path)-1) if self.graph[d_path[i]][d_path[i+1]].get("traffic_density", 0.0) >= 70.0]
        
        if accident_roads:
            reason = f"Detoured to avoid active accident zones on: {', '.join(accident_roads)}."
        elif congested_edges:
            reason = f"Optimal route selected bypassing heavy traffic on: {', '.join(congested_edges)}."
        else:
            reason = "Shortest route selected based on low congestion and open status."

        # Compile comparison results
        comparison_record = {
            "dijkstra": {"path": d_path, "length_km": d_len, "cost": d_cost, "time_ns": d_time, "memory_bytes": sys.getsizeof(d_path)},
            "astar": {"path": a_path, "length_km": a_len, "cost": a_cost, "time_ns": a_time, "memory_bytes": sys.getsizeof(a_path)}
        }

        # Reset accident blockages to leave graph clean for next query
        if accident_roads:
            for road in accident_roads:
                self.accident_analyzer.clear_accident_on_road(self.graph, road)

        return {
            "id": str(uuid.uuid4()),
            "vehicle_id": vehicle_id,
            "source": source,
            "destination": destination,
            "recommended_route": d_path,
            "alternative_route": alt_path,
            "eta": eta,
            "reason": reason,
            "timestamp": datetime.utcnow().isoformat(),
            "comparison": comparison_record
        }
