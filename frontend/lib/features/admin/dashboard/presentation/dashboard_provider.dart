import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vanet_mobile/models/vehicle_model.dart';
import 'package:vanet_mobile/models/alert_model.dart';
import 'package:vanet_mobile/models/trust_model.dart';
import 'package:vanet_mobile/models/explanation_model.dart';
import 'package:vanet_mobile/models/route_model.dart';

class DashboardState {
  final List<VehicleModel> vehicles;
  final List<AlertModel> alerts;
  final List<TrustModel> trustRankings;
  final Map<String, ExplanationModel> explanations;
  final Map<String, RouteModel> routes;
  final bool isLoading;
  final String? errorMessage;

  const DashboardState({
    required this.vehicles,
    required this.alerts,
    required this.trustRankings,
    required this.explanations,
    required this.routes,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Computes overall Network Risk Score (0 - 100)
  int get riskScore {
    if (vehicles.isEmpty && alerts.isEmpty) return 42;
    final suspicious = vehicles.where((v) => v.trustStatus.toLowerCase() == 'suspicious').length;
    final untrusted = vehicles.where((v) => v.trustStatus.toLowerCase() == 'untrusted' || v.trustStatus.toLowerCase() == 'malicious').length;
    final criticalAlerts = alerts.where((a) => a.severity.toLowerCase() == 'high' || a.severity.toLowerCase() == 'critical').length;
    
    // Weighted formula capped between 10 and 95
    final calculated = (suspicious * 8 + untrusted * 12 + criticalAlerts * 5);
    return calculated == 0 ? 15 : calculated.clamp(15, 95);
  }

  /// Categorizes Network Risk Level
  String get riskLevel {
    final score = riskScore;
    if (score >= 75) return 'High Risk';
    if (score >= 40) return 'Moderate Risk';
    return 'Low Risk';
  }

  DashboardState copyWith({
    List<VehicleModel>? vehicles,
    List<AlertModel>? alerts,
    List<TrustModel>? trustRankings,
    Map<String, ExplanationModel>? explanations,
    Map<String, RouteModel>? routes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return DashboardState(
      vehicles: vehicles ?? this.vehicles,
      alerts: alerts ?? this.alerts,
      trustRankings: trustRankings ?? this.trustRankings,
      explanations: explanations ?? this.explanations,
      routes: routes ?? this.routes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// --- Provider Implementation ---

class DashboardNotifier extends StateNotifier<DashboardState> {
  DashboardNotifier() : super(_initialState);

  static final _initialState = DashboardState(
    vehicles: [
      VehicleModel(
        id: 'V-101',
        speed: 48.5,
        acceleration: 1.2,
        direction: 'North',
        latitude: 33.6844,
        longitude: 73.0479,
        trustScore: 92.5,
        trustStatus: 'Trusted',
        lastActivity: DateTime.now().subtract(const Duration(seconds: 12)),
      ),
      VehicleModel(
        id: 'V-203',
        speed: 120.2,
        acceleration: 8.5,
        direction: 'West',
        latitude: 33.6934,
        longitude: 73.0589,
        trustScore: 54.0,
        trustStatus: 'Suspicious',
        lastActivity: DateTime.now().subtract(const Duration(seconds: 4)),
        attackType: 'Speed Anomaly',
      ),
      VehicleModel(
        id: 'V-305',
        speed: 25.0,
        acceleration: -0.5,
        direction: 'East',
        latitude: 33.7012,
        longitude: 73.0645,
        trustScore: 28.0,
        trustStatus: 'Untrusted',
        lastActivity: DateTime.now().subtract(const Duration(seconds: 1)),
        attackType: 'False Position Telemetry',
      ),
      VehicleModel(
        id: 'V-404',
        speed: 65.0,
        acceleration: 0.0,
        direction: 'South',
        latitude: 33.6744,
        longitude: 73.0379,
        trustScore: 99.0,
        trustStatus: 'Trusted',
        lastActivity: DateTime.now().subtract(const Duration(seconds: 30)),
        isEmergency: true,
      ),
      VehicleModel(
        id: 'V-509',
        speed: 98.0,
        acceleration: 4.2,
        direction: 'North-East',
        latitude: 33.7122,
        longitude: 73.0789,
        trustScore: 35.0,
        trustStatus: 'Untrusted',
        lastActivity: DateTime.now().subtract(const Duration(seconds: 2)),
        attackType: 'Fake Emergency Claim',
        isEmergency: true,
      ),
    ],
    alerts: [
      AlertModel(
        id: 'A-001',
        category: 'Security',
        title: 'Malicious Vehicle Detected',
        description: 'Vehicle V-305 flagged for injecting inconsistent coordinate position offsets.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        severity: 'High',
        vehicleId: 'V-305',
      ),
      AlertModel(
        id: 'A-002',
        category: 'Emergency',
        title: 'Fake Emergency Message',
        description: 'Vehicle V-509 broadcasted priority preemption request but failed PKI signature checks.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        severity: 'High',
        vehicleId: 'V-509',
      ),
      AlertModel(
        id: 'A-003',
        category: 'Emergency',
        title: 'Emergency Vehicle Approaching',
        description: 'Authenticated emergency ambulance V-404 requires priority transit warning flags.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        severity: 'Medium',
        vehicleId: 'V-404',
      ),
      AlertModel(
        id: 'A-004',
        category: 'Traffic',
        title: 'Accident Ahead',
        description: 'Collision detected on Route segment ROAD_BC. Dynamic detour routes generated.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
        severity: 'High',
      ),
      AlertModel(
        id: 'A-005',
        category: 'Traffic',
        title: 'Heavy Traffic Ahead',
        description: 'Vehicle density spike flagged near central intersection sector 9.',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        severity: 'Low',
      ),
    ],
    trustRankings: [
      const TrustModel(
        vehicleId: 'V-404',
        currentTrust: 99.0,
        previousTrust: 98.0,
        trustChange: 1.0,
        reason: 'Consistent certified kinematics and valid emergency credential signature.',
        trustHistory: [90, 93, 95, 98, 99],
        attackCount: 0,
      ),
      const TrustModel(
        vehicleId: 'V-101',
        currentTrust: 92.5,
        previousTrust: 91.0,
        trustChange: 1.5,
        reason: 'Normal communication pattern compliance (+1.5 trust recovery bonus applied).',
        trustHistory: [85, 87, 89, 91, 92.5],
        attackCount: 0,
      ),
      const TrustModel(
        vehicleId: 'V-203',
        currentTrust: 54.0,
        previousTrust: 80.0,
        trustChange: -26.0,
        reason: 'Abrupt kinematic acceleration profile discrepancy detected (-26 penalty points).',
        trustHistory: [95, 93, 85, 80, 54],
        attackCount: 1,
      ),
      const TrustModel(
        vehicleId: 'V-509',
        currentTrust: 35.0,
        previousTrust: 95.0,
        trustChange: -60.0,
        reason: 'Unauthorized attempt to spoof authenticated emergency beacon priority.',
        trustHistory: [97, 95, 95, 95, 35],
        attackCount: 1,
      ),
      const TrustModel(
        vehicleId: 'V-305',
        currentTrust: 28.0,
        previousTrust: 38.0,
        trustChange: -10.0,
        reason: 'Repeated position offsets out of standard range limits.',
        trustHistory: [60, 55, 48, 38, 28],
        attackCount: 3,
      ),
    ],
    explanations: {
      'V-203': const ExplanationModel(
        vehicleId: 'V-203',
        prediction: 'Malicious',
        confidence: 88.5,
        modelName: 'XGBoost Telemetry Classifier',
        attackType: 'Speed Anomaly',
        severity: 'High',
        humanReason: 'The vehicle is transmitting speeds exceeding physical limits (120 km/h) inconsistent with adjacent nodes.',
        shapValues: {
          'Speed Value': 0.55,
          'Acceleration Anomaly': 0.35,
          'GPS Position Delta': 0.05,
          'Signal Strengths': 0.03,
          'Message Intervals': 0.02,
        },
        limeValues: {
          'Speed Value': 0.62,
          'Acceleration Anomaly': 0.28,
          'GPS Position Delta': 0.04,
          'Signal Strengths': 0.04,
          'Message Intervals': 0.02,
        },
      ),
      'V-305': const ExplanationModel(
        vehicleId: 'V-305',
        prediction: 'Malicious',
        confidence: 96.2,
        modelName: 'LightGBM Spatial Classifier',
        attackType: 'False Position Telemetry',
        severity: 'Critical',
        humanReason: 'Large spatial delta discrepancies between GPS coordinates and RSSI radio range indicators.',
        shapValues: {
          'GPS Position Delta': 0.68,
          'Speed Value': 0.15,
          'Acceleration Anomaly': 0.08,
          'Message Intervals': 0.06,
          'Signal Strengths': 0.03,
        },
        limeValues: {
          'GPS Position Delta': 0.72,
          'Speed Value': 0.12,
          'Acceleration Anomaly': 0.06,
          'Message Intervals': 0.07,
          'Signal Strengths': 0.03,
        },
      ),
      'V-509': const ExplanationModel(
        vehicleId: 'V-509',
        prediction: 'Malicious',
        confidence: 94.5,
        modelName: 'Random Forest Threat Model',
        attackType: 'Fake Emergency Claim',
        severity: 'Critical',
        humanReason: 'Vehicle claimed Ambulance siren status, but the associated cryptographic key failed PKI signature verification.',
        shapValues: {
          'PKI Sign Status': 0.82,
          'Speed Value': 0.08,
          'Acceleration Anomaly': 0.05,
          'GPS Position Delta': 0.03,
          'Message Intervals': 0.02,
        },
        limeValues: {
          'PKI Sign Status': 0.85,
          'Speed Value': 0.06,
          'Acceleration Anomaly': 0.04,
          'GPS Position Delta': 0.03,
          'Message Intervals': 0.02,
        },
      ),
    },
    routes: {
      'V-404': const RouteModel(
        vehicleId: 'V-404',
        type: 'Ambulance',
        distance: '3.8 km',
        eta: '5 mins',
        traffic: 'Moderate',
        incidentStatus: 'Accident active on Main Highway Sector 4 (Detour Active)',
        recommendationReason: 'Detoured from Route A to Route B via A* solver to avoid traffic gridlock due to accident.',
        recommendedPath: ['Start (Sector 1)', 'Interlink A', 'Alternative Route B', 'Intersection 5', 'Hospital (Sector 4)'],
        alternativePath: ['Start (Sector 1)', 'Main Highway (Blocked)', 'Intersection 3', 'Hospital (Sector 4)'],
        priority: 'Critical',
        isAuthenticated: true,
      ),
    },
  );

  /// Dismisses / deletes alert
  void dismissAlert(String id) {
    state = state.copyWith(
      alerts: state.alerts.where((a) => a.id != id).toList(),
    );
  }

  /// Simulates async data refresh / API re-fetch
  Future<void> refreshData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 600));
    state = state.copyWith(isLoading: false);
  }

  /// Sets custom error state for error testing
  void setError(String? error) {
    state = state.copyWith(errorMessage: error, isLoading: false);
  }

  /// Appends alert
  void addAlert(AlertModel alert) {
    state = state.copyWith(
      alerts: [alert, ...state.alerts],
    );
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier();
});
