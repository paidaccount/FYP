class VehicleModel {
  final String id;
  final double speed;
  final double acceleration;
  final String direction;
  final double latitude;
  final double longitude;
  final double trustScore;
  final String trustStatus; // 'Trusted', 'Suspicious', 'Untrusted'
  final DateTime lastActivity;
  final String attackType;
  final bool isEmergency;

  const VehicleModel({
    required this.id,
    required this.speed,
    required this.acceleration,
    required this.direction,
    required this.latitude,
    required this.longitude,
    required this.trustScore,
    required this.trustStatus,
    required this.lastActivity,
    this.attackType = 'None',
    this.isEmergency = false,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      speed: (json['speed'] as num).toDouble(),
      acceleration: (json['acceleration'] as num).toDouble(),
      direction: json['direction'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      trustScore: (json['trustScore'] as num).toDouble(),
      trustStatus: json['trustStatus'] as String,
      lastActivity: DateTime.parse(json['lastActivity'] as String),
      attackType: json['attackType'] as String? ?? 'None',
      isEmergency: json['isEmergency'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'speed': speed,
      'acceleration': acceleration,
      'direction': direction,
      'latitude': latitude,
      'longitude': longitude,
      'trustScore': trustScore,
      'trustStatus': trustStatus,
      'lastActivity': lastActivity.toIso8601String(),
      'attackType': attackType,
      'isEmergency': isEmergency,
    };
  }
}
