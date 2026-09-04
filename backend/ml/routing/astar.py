import networkx as nx
from typing import List, Dict, Any, Tuple
from app.services.routing.route_config import NODE_COORDINATES

class AStarPathfinder:
    """
    Finds the shortest/least-cost path using the A* algorithm
    with Euclidean distance heuristic.
    """
    def heuristic(self, u: str, v: str) -> float:
        """Heuristic function evaluating physical straight-line distance to destination."""
        if u not in NODE_COORDINATES or v not in NODE_COORDINATES:
            return 0.0
        
        ux, uy = NODE_COORDINATES[u]
        vx, vy = NODE_COORDINATES[v]
        return ((ux - vx) ** 2 + (uy - vy) ** 2) ** 0.5

    def find_route(self, graph: nx.Graph, source: str, target: str) -> Tuple[List[str], float, float]:
        """
        Computes least-cost path based on edge 'cost' weights and destination heuristics.
        """
        try:
            path = nx.astar_path(
                graph, 
                source, 
                target, 
                heuristic=self.heuristic, 
                weight="cost"
            )
            
            # Calculate metrics
            total_length = 0.0
            total_cost = 0.0
            for i in range(len(path) - 1):
                u, v = path[i], path[i+1]
                edge_data = graph[u][v]
                total_length += edge_data.get("distance", 0.0)
                total_cost += edge_data.get("cost", 0.0)

            return path, total_length, total_cost
        except nx.NetworkXNoPath:
            return [], 0.0, float("inf")
        except Exception as e:
            print(f"A* search failed: {str(e)}")
            return [], 0.0, float("inf")
