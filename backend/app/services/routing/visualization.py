import os
import matplotlib
matplotlib.use("Agg") # Avoid server GUI failures
import matplotlib.pyplot as plt
import networkx as nx
from typing import Dict, List, Any
from app.services.routing.route_config import ROUTING_PLOTS_DIR, NODE_COORDINATES

class RouteVisualizer:
    """
    Renders and exports graphical routing maps:
    - Node network graphs with colorized traffic edges
    - Algorithm execution benchmarking performance comparisons
    """
    def __init__(self, plot_dir=ROUTING_PLOTS_DIR):
        self.plot_dir = plot_dir
        os.makedirs(self.plot_dir, exist_ok=True)

    def plot_road_network(self, graph: nx.Graph, filename: str, path_overlay: List[str] = None) -> None:
        """
        Plots the road connection graph.
        - Edges colored by traffic level: Green (Low), Orange (Medium), Red (Heavy).
        - Recommended path overlay highlighted in thick blue.
        """
        try:
            plt.figure(figsize=(10, 8))
            pos = NODE_COORDINATES # Use predefined grid positions

            # 1. Resolve edge colors based on traffic density
            edge_colors = []
            edge_widths = []
            for u, v, attrs in graph.edges(data=True):
                # Highlight recommended path overlay if provided
                if path_overlay and u in path_overlay and v in path_overlay and abs(path_overlay.index(u) - path_overlay.index(v)) == 1:
                    edge_colors.append("blue")
                    edge_widths.append(4.0)
                else:
                    density = attrs.get("traffic_density", 0.0)
                    status = attrs.get("road_status", "OPEN")
                    if status == "BLOCKED":
                        edge_colors.append("black")
                        edge_widths.append(2.5)
                    elif density >= 70.0:
                        edge_colors.append("crimson")
                        edge_widths.append(2.0)
                    elif density >= 30.0:
                        edge_colors.append("orange")
                        edge_widths.append(1.5)
                    else:
                        edge_colors.append("forestgreen")
                        edge_widths.append(1.0)

            # 2. Draw nodes and label names
            nx.draw_networkx_nodes(graph, pos, node_size=600, node_color="skyblue", edgecolors="black")
            nx.draw_networkx_labels(graph, pos, font_size=12, font_weight="bold")

            # 3. Draw edges with dynamic colors
            nx.draw_networkx_edges(graph, pos, edge_color=edge_colors, width=edge_widths)

            # 4. Draw edge labels showing distance and density
            edge_labels = {}
            for u, v, attrs in graph.edges(data=True):
                dist = attrs.get("distance", 1.0)
                dens = attrs.get("traffic_density", 0.0)
                status = attrs.get("road_status", "OPEN")
                label = f"{dist}km\n({int(dens)}%)"
                if status == "BLOCKED":
                    label = "BLOCKED"
                edge_labels[(u, v)] = label
                
            nx.draw_networkx_edge_labels(graph, pos, edge_labels=edge_labels, font_size=8)

            plt.title("VANET Road Graph Network and Traffic Heatmap", fontsize=12)
            plt.axis("off")
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, filename))
            plt.close()
        except Exception as e:
            print(f"Failed plotting road network graph: {str(e)}")

    def plot_algorithm_comparison(self, d_time_ns: float, a_time_ns: float) -> None:
        """Plots bar chart comparing Dijkstra and A* pathfinders execution times."""
        try:
            plt.figure(figsize=(6, 4))
            algos = ["Dijkstra's Algorithm", "A* Algorithm"]
            times = [d_time_ns, a_time_ns]
            
            plt.bar(algos, times, color=["indigo", "teal"], edgecolor="black", width=0.4)
            plt.title("Pathfinders Query Execution Speed Comparison", fontsize=11)
            plt.ylabel("Execution Time (Nanoseconds)")
            plt.grid(True, alpha=0.3, axis="y")
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, "algorithm_comparison.png"))
            plt.close()
        except Exception as e:
            print(f"Failed plotting algorithm comparison: {str(e)}")
