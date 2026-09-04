import networkx as nx
from typing import Dict, Any

class VANETGraphBuilder:
    """
    Builds and maintains the NetworkX Graph layout representing intersections 
    and connecting roads with kinematic attributes.
    """
    def __init__(self):
        self.graph = nx.Graph()

    def build_default_network(self) -> nx.Graph:
        """
        Populates intersections as nodes and roads as edges with initial parameters:
        distance (km), speed_limit (km/h), traffic_density (0-100), road_status (OPEN/BLOCKED).
        """
        # Node coordinates are stored in configuration
        nodes = ["A", "B", "C", "D", "E", "F"]
        self.graph.add_nodes_from(nodes)

        # Connect segments: (start_node, end_node, edge_attributes)
        edges = [
            ("A", "B", {"road_id": "ROAD_AB", "distance": 5.0, "speed_limit": 60.0, "traffic_density": 10.0, "road_status": "OPEN", "accident_status": False}),
            ("A", "D", {"road_id": "ROAD_AD", "distance": 5.0, "speed_limit": 50.0, "traffic_density": 20.0, "road_status": "OPEN", "accident_status": False}),
            ("B", "C", {"road_id": "ROAD_BC", "distance": 5.0, "speed_limit": 60.0, "traffic_density": 80.0, "road_status": "OPEN", "accident_status": False}),
            ("D", "C", {"road_id": "ROAD_DC", "distance": 5.0, "speed_limit": 50.0, "traffic_density": 15.0, "road_status": "OPEN", "accident_status": False}),
            ("C", "E", {"road_id": "ROAD_CE", "distance": 5.0, "speed_limit": 70.0, "traffic_density": 25.0, "road_status": "OPEN", "accident_status": False}),
            ("C", "F", {"road_id": "ROAD_CF", "distance": 8.0, "speed_limit": 80.0, "traffic_density": 30.0, "road_status": "OPEN", "accident_status": False}),
            ("E", "F", {"road_id": "ROAD_EF", "distance": 5.0, "speed_limit": 60.0, "traffic_density": 20.0, "road_status": "OPEN", "accident_status": False})
        ]

        for u, v, attrs in edges:
            self.graph.add_edge(u, v, **attrs)

        return self.graph
