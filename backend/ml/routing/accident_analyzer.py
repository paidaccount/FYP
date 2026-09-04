import networkx as nx
from typing import List

class AccidentAnalyzer:
    """
    Updates road segments states dynamically in the NetworkX graph 
    representing accident location blockages.
    """
    def register_accident_on_road(self, graph: nx.Graph, road_id: str) -> None:
        """
        Flags the road segment status to BLOCKED.
        """
        for u, v, attrs in graph.edges(data=True):
            if attrs.get("road_id") == road_id:
                graph[u][v]["road_status"] = "BLOCKED"
                graph[u][v]["accident_status"] = True
                break

    def clear_accident_on_road(self, graph: nx.Graph, road_id: str) -> None:
        """
        Restores road status to OPEN.
        """
        for u, v, attrs in graph.edges(data=True):
            if attrs.get("road_id") == road_id:
                graph[u][v]["road_status"] = "OPEN"
                graph[u][v]["accident_status"] = False
                break
