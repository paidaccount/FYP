import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanet_mobile/models/vehicle_model.dart';
import 'package:vanet_mobile/models/alert_model.dart';

class DriverState {
  final String vehicleId;
  final String licensePlate;
  final String vehicleType;
  final double currentSpeed;
  final double trustScore;
  final String trustStatus;
  final bool isOBUOnline;
  final bool isEmergencyModeActive;
  final List<VehicleModel> nearbyVehicles;
  final List<AlertModel> activeAlerts;
  final List<Map<String, dynamic>> safetyHistory;

  const DriverState({
    this.vehicleId = 'PK-V8942',
    this.licensePlate = 'LEB-2024-942',
    this.vehicleType = 'Civilian Sedan / Hybrid',
    this.currentSpeed = 54.0,
    this.trustScore = 0.94,
    this.trustStatus = 'Trusted',
    this.isOBUOnline = true,
    this.isEmergencyModeActive = false,
    this.nearbyVehicles = const [],
    this.activeAlerts = const [],
    this.safetyHistory = const [],
  });

  DriverState copyWith({
    String? vehicleId,
    String? licensePlate,
    String? vehicleType,
    double? currentSpeed,
    double? trustScore,
    String? trustStatus,
    bool? isOBUOnline,
    bool? isEmergencyModeActive,
    List<VehicleModel>? nearbyVehicles,
    List<AlertModel>? activeAlerts,
    List<Map<String, dynamic>>? safetyHistory,
  }) {
    return DriverState(
      vehicleId: vehicleId ?? this.vehicleId,
      licensePlate: licensePlate ?? this.licensePlate,
      vehicleType: vehicleType ?? this.vehicleType,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      trustScore: trustScore ?? this.trustScore,
      trustStatus: trustStatus ?? this.trustStatus,
      isOBUOnline: isOBUOnline ?? this.isOBUOnline,
      isEmergencyModeActive: isEmergencyModeActive ?? this.isEmergencyModeActive,
      nearbyVehicles: nearbyVehicles ?? this.nearbyVehicles,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      safetyHistory: safetyHistory ?? this.safetyHistory,
    );
  }
}

class DriverNotifier extends StateNotifier<DriverState> {
  DriverNotifier()
      : super(
          DriverState(
            nearbyVehicles: [
              VehicleModel(
                id: 'V1023',
                speed: 98.4,
                acceleration: 4.2,
                direction: 'North',
                latitude: 33.6844,
                longitude: 73.0479,
                trustScore: 0.22,
                trustStatus: 'Untrusted',
                lastActivity: DateTime.now().subtract(const Duration(seconds: 4)),
                attackType: 'False Speed Injection',
                isEmergency: false,
              ),
              VehicleModel(
                id: 'V4091',
                speed: 52.0,
                acceleration: 0.5,
                direction: 'North-East',
                latitude: 33.6890,
                longitude: 73.0510,
                trustScore: 0.88,
                trustStatus: 'Trusted',
                lastActivity: DateTime.now().subtract(const Duration(seconds: 2)),
                attackType: 'None',
                isEmergency: false,
              ),
              VehicleModel(
                id: 'AMB-1122',
                speed: 84.0,
                acceleration: 2.8,
                direction: 'North',
                latitude: 33.6810,
                longitude: 73.0460,
                trustScore: 0.99,
                trustStatus: 'Trusted',
                lastActivity: DateTime.now().subtract(const Duration(seconds: 1)),
                attackType: 'None',
                isEmergency: true,
              ),
              VehicleModel(
                id: 'V8812',
                speed: 61.2,
                acceleration: -1.1,
                direction: 'East',
                latitude: 33.6870,
                longitude: 73.0430,
                trustScore: 0.51,
                trustStatus: 'Suspicious',
                lastActivity: DateTime.now().subtract(const Duration(seconds: 8)),
                attackType: 'Position Drift',
                isEmergency: false,
              ),
            ],
            activeAlerts: [
              AlertModel(
                id: 'ALT-901',
                category: 'Emergency',
                title: 'Emergency Vehicle Approaching',
                description: 'Rescue 1122 Ambulance approaching 350m behind in Northbound lane. Please yield right of way.',
                severity: 'High',
                timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
                vehicleId: 'AMB-1122',
              ),
              AlertModel(
                id: 'ALT-902',
                category: 'Security',
                title: 'Suspicious Telemetry Ahead',
                description: 'Vehicle V1023 (120m ahead) broadcasting conflicting kinematic data. AI advises 20m safety distance.',
                severity: 'High',
                timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
                vehicleId: 'V1023',
              ),
              AlertModel(
                id: 'ALT-903',
                category: 'Traffic',
                title: 'Sudden Road Hazard',
                description: 'Roadside Unit #4 reports slippery road surface & lane narrowing at Sector F-8 junction.',
                severity: 'Medium',
                timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
                vehicleId: 'RSU-04',
              ),
            ],
            safetyHistory: [
              {
                'title': 'Emergency Corridor Yielded',
                'detail': 'Successfully cleared lane for AMB-1122 preemption corridor.',
                'time': '10 mins ago',
                'type': 'safe',
              },
              {
                'title': 'Malicious Broadcast Filtered',
                'detail': 'OBU rejected ghost vehicle packet from rogue node V9901.',
                'time': '45 mins ago',
                'type': 'warning',
              },
              {
                'title': 'AI Detour Taken',
                'detail': 'Rerouted via 7th Avenue to avoid congested Sybil attack cluster.',
                'time': '2 hours ago',
                'type': 'info',
              },
              {
                'title': 'OBU Trust Score Verified',
                'detail': 'Direct & indirect trust evaluated at 0.94 (Excellent rating).',
                'time': 'Today, 08:30 AM',
                'type': 'safe',
              },
            ],
          ),
        );

  void toggleEmergencyMode() {
    state = state.copyWith(isEmergencyModeActive: !state.isEmergencyModeActive);
  }

  void updateSpeed(double newSpeed) {
    state = state.copyWith(currentSpeed: newSpeed);
  }

  void dismissAlert(String alertId) {
    state = state.copyWith(
      activeAlerts: state.activeAlerts.where((a) => a.id != alertId).toList(),
    );
  }
}

final driverProvider = StateNotifierProvider<DriverNotifier, DriverState>((ref) {
  return DriverNotifier();
});
