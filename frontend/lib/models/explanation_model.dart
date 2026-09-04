class ExplanationModel {
  final String vehicleId;
  final String prediction; // 'Normal' or 'Malicious'
  final double confidence;
  final String modelName;
  final String attackType;
  final String severity;
  final String humanReason;
  final Map<String, double> shapValues;
  final Map<String, double> limeValues;

  const ExplanationModel({
    required this.vehicleId,
    required this.prediction,
    required this.confidence,
    required this.modelName,
    required this.attackType,
    required this.severity,
    required this.humanReason,
    required this.shapValues,
    required this.limeValues,
  });

  factory ExplanationModel.fromJson(Map<String, dynamic> json) {
    return ExplanationModel(
      vehicleId: json['vehicleId'] as String,
      prediction: json['prediction'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      modelName: json['modelName'] as String,
      attackType: json['attackType'] as String,
      severity: json['severity'] as String,
      humanReason: json['humanReason'] as String,
      shapValues: (json['shapValues'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble())),
      limeValues: (json['limeValues'] as Map<String, dynamic>).map((k, v) => MapEntry(k, (v as num).toDouble())),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleId': vehicleId,
      'prediction': prediction,
      'confidence': confidence,
      'modelName': modelName,
      'attackType': attackType,
      'severity': severity,
      'humanReason': humanReason,
      'shapValues': shapValues,
      'limeValues': limeValues,
    };
  }
}
