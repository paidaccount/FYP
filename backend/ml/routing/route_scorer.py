import networkx as nx
from app.services.routing.route_config import (
    WEIGHT_DISTANCE,
    WEIGHT_CONGESTION,
    WEIGHT_ACCIDENT_RISK
)

class RouteScorer:
    """
    Evaluates dynamic edge cost coefficients factoring distance, congestion, 
    and blockages.
    """
    def calculate_edge_cost(self, u: str, v: str, edge_attrs: dict) -> float:
        """
        Computes dynamic cost value for an edge. Returns a massive number if blocked.
        """
        if edge_attrs.get("road_status") == "BLOCKED":
            return 1e9 # Infinite cost (Blocked)

        distance = edge_attrs.get("distance", 1.0)
        density = edge_attrs.get("traffic_density", 0.0)
        accident = edge_attrs.get("accident_status", False)

        # Scale traffic density (0 to 100) to match distance scale
        traffic_factor = density / 10.0 # scale factor to normalize cost

        # Scale accident status risk
        accident_factor = 50.0 if accident else 0.0

        # Compute dynamic cost
        cost = (
            (distance * WEIGHT_DISTANCE) +
            (traffic_factor * WEIGHT_CONGESTION) +
            (accident_factor * WEIGHT_ACCIDENT_RISK)
        )
        return float(cost)

    def apply_costs_to_graph(self, graph: nx.Graph) -> None:
        """
        Applies calculated cost scores onto graph edges under the weight name 'cost'.
        """
        for u, v, attrs in graph.edges(data=True):
            graph[u][v]["cost"] = self.calculate_edge_cost(u, v, attrs)
            # Travel time estimation in seconds: Distance / (Speed Limit adjusted by traffic)
            speed = attrs.get("speed_limit", 50.0)
            density = attrs.get("traffic_density", 0.0)
            
            # Reduce speed dynamically as traffic density increases
            adjusted_speed = speed * (1.0 - (density / 120.0))
            adjusted_speed = max(adjusted_speed, 5.0) # minimum 5 km/h
            
            # Time = Distance (km) / Speed (km/h) * 3600 (seconds/hour)
            graph[u][v]["travel_time"] = (attrs.get("distance", 1.0) / adjusted_speed) * 3600.0
