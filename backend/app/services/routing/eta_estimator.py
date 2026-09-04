import networkx as nx
from typing import List

class ETAEstimator:
    """
    Estimates estimated travel arrival times (ETA) across a list of nodes.
    """
    def estimate_route_eta(self, graph: nx.Graph, path: List[str]) -> float:
        """
        Sums up travel_time (seconds) on edges, returning total minutes.
        """
        if not path or len(path) < 2:
            return 0.0

        total_seconds = 0.0
        for i in range(len(path) - 1):
            u, v = path[i], path[i+1]
            if graph.has_edge(u, v):
                total_seconds += graph[u][v].get("travel_time", 0.0)

        # Convert to minutes and round to 1 decimal
        return round(total_seconds / 60.0, 1)
