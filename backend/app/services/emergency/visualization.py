import os
import matplotlib
matplotlib.use("Agg") # Avoid server GUI failures
import matplotlib.pyplot as plt
from typing import Dict, List, Any
from app.services.emergency.emergency_config import EMERGENCY_PLOTS_DIR

class EmergencyVisualizer:
    """
    Renders and exports graphical charts for emergency priorities dashboards:
    - Status counts pie charts
    - Fake claims ratio bar charts
    - Priority distribution histograms
    """
    def __init__(self, plot_dir=EMERGENCY_PLOTS_DIR):
        self.plot_dir = plot_dir
        os.makedirs(self.plot_dir, exist_ok=True)

    def plot_priority_distribution(self, priorities: List[str]) -> None:
        """Plots bar chart showing priority distribution of active requests."""
        try:
            plt.figure(figsize=(8, 4))
            levels = ["Low", "Medium", "High", "Critical"]
            counts = [priorities.count(l) for l in levels]
            
            colors = ["blue", "yellow", "orange", "red"]
            
            plt.bar(levels, counts, color=colors, edgecolor="black", width=0.5)
            plt.title("Priority Level Distribution of Dispatch Requests", fontsize=12)
            plt.xlabel("Priority Level")
            plt.ylabel("Active Alerts Count")
            plt.grid(True, alpha=0.3, axis="y")
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, "priority_distribution.png"))
            plt.close()
        except Exception as e:
            print(f"Failed plotting priority distribution: {str(e)}")

    def plot_emergency_statuses(self, statuses: List[str]) -> None:
        """Plots pie chart of emergency vehicle operation statuses."""
        try:
            plt.figure(figsize=(6, 6))
            unique_statuses = list(set(statuses))
            counts = [statuses.count(s) for s in unique_statuses]
            
            plt.pie(counts, labels=unique_statuses, autopct='%1.1f%%', colors=["green", "orange", "red"])
            plt.title("Emergency Vehicles Operational Status", fontsize=12)
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, "status_dashboard.png"))
            plt.close()
        except Exception as e:
            print(f"Failed plotting statuses: {str(e)}")

    def plot_fake_statistics(self, total: int, fakes: int) -> None:
        """Plots bar chart showing authenticated vs spoofed emergency claims."""
        try:
            plt.figure(figsize=(7, 4))
            categories = ["Authenticated Claims", "Fake Claims Detected"]
            values = [total - fakes, fakes]
            
            plt.bar(categories, values, color=["darkgreen", "crimson"], edgecolor="black", width=0.4)
            plt.title("Emergency Claim Verification Statistics", fontsize=12)
            plt.ylabel("Number of Messages")
            plt.grid(True, alpha=0.3, axis="y")
            plt.tight_layout()
            
            plt.savefig(os.path.join(self.plot_dir, "fake_statistics.png"))
            plt.close()
        except Exception as e:
            print(f"Failed plotting fake statistics: {str(e)}")
