class TrustModel {
  final String vehicleId;
  final double currentTrust;
  final double previousTrust;
  final double trustChange;
  final String reason;
  final List<double> trustHistory;
  final int attackCount;

  const TrustModel({
    required this.vehicleId,
    required this.currentTrust,
    required this.previousTrust,
    required this.trustChange,
    required this.reason,
    required this.trustHistory,
    required this.attackCount,
  });

  factory TrustModel.fromJson(Map<String, dynamic> json) {
    return TrustModel(
      vehicleId: json['vehicleId'] as String,
      currentTrust: (json['currentTrust'] as num).toDouble(),
      previousTrust: (json['previousTrust'] as num).toDouble(),
      trustChange: (json['trustChange'] as num).toDouble(),
      reason: json['reason'] as String,
      trustHistory: (json['trustHistory'] as List<dynamic>).map((e) => (e as num).toDouble()).toList(),
      attackCount: json['attackCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'currentTrust': currentTrust,
      'previousTrust': previousTrust,
      'trustChange': trustChange,
      'reason': reason,
      'trustHistory': trustHistory,
      'attackCount': attackCount,
    };
  }
}
