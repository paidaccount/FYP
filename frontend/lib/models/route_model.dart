class RouteModel {
  final String vehicleId;
  final String type; // 'Ambulance', 'Police', 'Fire Brigade', 'Rescue'
  final String distance;
  final String eta;
  final String traffic;
  final String incidentStatus;
  final String recommendationReason;
  final List<String> recommendedPath;
  final List<String> alternativePath;
  final String priority; // 'Critical', 'High', 'Standard'
  final bool isAuthenticated;

  const RouteModel({
    required this.vehicleId,
    required this.type,
    required this.distance,
    required this.eta,
    required this.traffic,
    required this.incidentStatus,
    required this.recommendationReason,
    required this.recommendedPath,
    required this.alternativePath,
    required this.priority,
    required this.isAuthenticated,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      vehicleId: json['vehicleId'] as String,
      type: json['type'] as String,
      distance: json['distance'] as String,
      eta: json['eta'] as String,
      traffic: json['traffic'] as String,
      incidentStatus: json['incidentStatus'] as String,
      recommendationReason: json['recommendationReason'] as String,
      recommendedPath: List<String>.from(json['recommendedPath'] as List<dynamic>),
      alternativePath: List<String>.from(json['alternativePath'] as List<dynamic>),
      priority: json['priority'] as String,
      isAuthenticated: json['isAuthenticated'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'type': type,
      'distance': distance,
      'eta': eta,
      'traffic': traffic,
      'incidentStatus': incidentStatus,
      'recommendationReason': recommendationReason,
      'recommendedPath': recommendedPath,
      'alternativePath': alternativePath,
      'priority': priority,
      'isAuthenticated': isAuthenticated,
    };
  }
}
