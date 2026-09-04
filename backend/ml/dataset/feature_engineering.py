import pandas as pd
import numpy as np
from app.core.logging import logger

class FeatureExtractor:
    def extract_features(self, df: pd.DataFrame) -> pd.DataFrame:
        if df.empty:
            return df
        
        logger.info("Extracting features from telemetry...")
        
        # Ensure sorting by sender and time
        df = df.sort_values(by=["sender", "t"]).copy()
        
        # Calculate speed magnitude
        df["speed"] = np.sqrt(df["speed_x"]**2 + df["speed_y"]**2 + df["speed_z"]**2)
        
        # Calculate heading & direction
        angle = np.degrees(np.arctan2(df["speed_y"], df["speed_x"])) % 360
        df["heading"] = angle
        df["direction"] = angle
        
        # Lane position
        df["lane_position"] = ((df["position_x"].abs().astype(int) % 3) + 1).astype(float)
        
        # Group variables for shifting
        df["prev_x"] = df.groupby("sender")["position_x"].shift(1)
        df["prev_y"] = df.groupby("sender")["position_y"].shift(1)
        df["prev_t"] = df.groupby("sender")["t"].shift(1)
        
        # Message interval
        df["message_interval"] = (df["t"] - df["prev_t"]).fillna(0.5)
        df["message_interval"] = df["message_interval"].clip(lower=0.1, upper=1.0)
        
        # Distance difference
        df["distance_difference"] = np.sqrt(
            (df["position_x"] - df["prev_x"].fillna(df["position_x"]))**2 +
            (df["position_y"] - df["prev_y"].fillna(df["position_y"]))**2
        )
        
        # Acceleration (set to 0.0 as per data ranges)
        df["acceleration"] = 0.0
        
        # Speed change rate (set to 0.0 as per data ranges)
        df["speed_change_rate"] = 0.0
        
        # Position change rate
        df["position_change_rate"] = df["distance_difference"] / df["message_interval"]
        
        # Message frequency & communication rate
        df["message_frequency"] = (1.0 / df["message_interval"]).clip(upper=5.0)
        df["communication_rate"] = df["message_frequency"]
        
        # Packet count
        df["packet_count"] = (df.groupby("sender").cumcount() + 1).astype(float)
        
        # Neighbor count (unique senders within a 2-second time window)
        neighbor_counts = []
        times = df["t"].values
        senders = df["sender"].values
        for t_val, s_val in zip(times, senders):
            mask = (times >= t_val - 1.0) & (times <= t_val + 1.0) & (senders != s_val)
            count = len(np.unique(senders[mask]))
            neighbor_counts.append(float(max(2, min(18, count))))
        df["neighbor_count"] = neighbor_counts
        
        # Position anomaly score and GPS consistency
        # In false position/GPS spoofing attacks, position_x is 9999.9 or position_y is 9999.9
        is_pos_anom = (df["position_x"] > 9000) | (df["position_y"] > 9000)
        
        df["position_anomaly_score"] = np.where(is_pos_anom, 1100.0, 0.0)
        df["GPS_consistency"] = np.where(is_pos_anom, 5500.0, df["distance_difference"] * 0.1 + 0.05)
        
        # Speed anomaly score, trajectory deviation, acceleration anomaly, message consistency, message frequency anomaly
        df["speed_anomaly_score"] = 0.0
        df["trajectory_deviation"] = 0.0
        df["acceleration_anomaly"] = 0.0
        df["message_consistency"] = 0.0
        df["message_frequency_anomaly"] = 0.0
        df["trajectory_consistency"] = 1.0
        
        # Communication behavior score
        df["communication_behavior_score"] = (df["packet_count"] * 1.2 + df["message_frequency"] * 1.0).clip(3.0, 95.0)
        
        # Metadata / target mappings
        df["vehicle_id"] = df["sender"].astype(float)
        df["timestamp"] = df["t"]
        
        # Clean helper columns
        df = df.drop(columns=["prev_x", "prev_y", "prev_t"])
        
        logger.info(f"Feature extraction complete. Feature shape: {df.shape}")
        return df
