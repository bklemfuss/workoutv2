class BodyMeasurement {
  final int? bodyMeasurementId;
  final int userId;
  final String date;
  final double weight;

  BodyMeasurement({
    this.bodyMeasurementId,
    required this.userId,
    required this.date,
    required this.weight,
  });

  factory BodyMeasurement.fromMap(Map<String, dynamic> map) {
    return BodyMeasurement(
      bodyMeasurementId: map['body_measurement_id'],
      userId: map['user_id'],
      date: map['date'],
      weight: map['weight'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'body_measurement_id': bodyMeasurementId,
      'user_id': userId,
      'date': date,
      'weight': weight,
    };
  }
}