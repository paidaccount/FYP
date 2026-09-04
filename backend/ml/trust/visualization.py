import os
import matplotlib
matplotlib.use("Agg") # Avoid server GUI failures
import matplotlib.pyplot as plt
from typing import Dict, List, Any
from app.services.trust_config import TRUST_PLOTS_DIR

class TrustVisualizer:
    """
    Renders and exports graphical trust tracking analytics:
    - Trust score progression timeline charts
    - Overall score distribution histograms
    - Sorted vehicles ranking bar graphs
    """
    def __init__(self, plot_dir=TRUST_PLOTS_DIR):
        self.plot_dir = plot_dir
        os.makedirs(self.plot_dir, exist_ok=True)

    def plot_trust_timeline(self, vehicle_id: str, trust_history: List[float]) -> None:
        """Plots score trends over simulation epochs."""
        try:
            plt.figure(figsize=(10, 4))
            plt.plot(trust_history, marker="o", color="blue", linewidth=2, label="Trust Score")
            
            # Draw boundary lines
            plt.axhline(y=80.0, color="green", linestyle="--", alpha=0.6, label="Trusted Boundary")
            plt.axhline(y=40.0, color="orange", linestyle="--", alpha=0.6, label="Suspicious Boundary")
            
            plt.title(f"Trust Score Progression Timeline for {vehicle_id}", fontsize=12)
            plt.xlabel("Epoch Iteration")
            plt.ylabel("Trust Score (0-100)")
            plt.ylim(0, 105)
            plt.grid(True, alpha=0.3)
            plt.legend()
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, f"{vehicle_id}_timeline.png"))
            plt.close()
        except Exception as e:
            print(f"Failed plotting trust timeline: {str(e)}")

    def plot_trust_distribution(self, scores: List[float]) -> None:
        """Plots histogram showing distribution of scores across active vehicles."""
        try:
            plt.figure(figsize=(8, 4))
            plt.hist(scores, bins=10, color="purple", edgecolor="black", alpha=0.7)
            plt.axvline(x=80.0, color="green", linestyle="--")
            plt.axvline(x=40.0, color="orange", linestyle="--")
            
            plt.title("Active Fleet Trust Distribution", fontsize=12)
            plt.xlabel("Trust Score")
            plt.ylabel("Number of Vehicles")
            plt.xlim(0, 100)
            plt.grid(True, alpha=0.3)
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, "trust_distribution.png"))
            plt.close()
        except Exception as e:
            print(f"Failed plotting trust distribution: {str(e)}")

    def plot_vehicle_rankings(self, rankings: List[Dict[str, Any]]) -> None:
        """Plots sorted vehicle ranking bar chart."""
        try:
            plt.figure(figsize=(10, 5))
            vehicle_ids = [r["vehicle_id"] for r in rankings]
            scores = [r["trust_score"] for r in rankings]
            
            colors = ["green" if s >= 80 else ("orange" if s >= 40 else "red") for s in scores]
            
            plt.bar(vehicle_ids, scores, color=colors, edgecolor="black", width=0.6)
            plt.title("Fleet Security Trust Rankings", fontsize=12)
            plt.xlabel("Vehicle Identifier")
            plt.ylabel("Composite Trust Score")
            plt.ylim(0, 105)
            plt.grid(True, alpha=0.3, axis="y")
            plt.xticks(rotation=15)
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, "trust_rankings.png"))
            plt.close()
        except Exception as e:
            print(f"Failed plotting rankings: {str(e)}")
