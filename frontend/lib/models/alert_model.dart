class AlertModel {
  final String id;
  final String category; // 'Security', 'Emergency', 'Traffic', 'Trust'
  final String title;
  final String description;
  final DateTime timestamp;
  final String severity; // 'High', 'Medium', 'Low'
  final String? vehicleId;

  const AlertModel({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.severity,
    this.vehicleId,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as String,
      category: json['category'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      severity: json['severity'] as String,
      vehicleId: json['vehicleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'severity': severity,
      'vehicleId': vehicleId,
    };
  }
}
