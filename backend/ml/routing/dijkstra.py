import networkx as nx
from typing import List, Dict, Any, Tuple

class DijkstraPathfinder:
    """
    Finds the shortest/least-cost path using Dijkstra's algorithm.
    """
    def find_route(self, graph: nx.Graph, source: str, target: str) -> Tuple[List[str], float, float]:
        """
        Computes shortest path based on edge 'cost' weights.
        Returns:
            - Path nodes list (e.g. ['A', 'D', 'C'])
            - Total path length in km
            - Summed path cost
        """
        try:
            path = nx.dijkstra_path(graph, source, target, weight="cost")
            
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
            print(f"Dijkstra search failed: {str(e)}")
            return [], 0.0, float("inf")
