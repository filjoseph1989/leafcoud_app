class SensorCalibration {
  final int id;
  final String sensorName;
  final bool isCalibrating;
  final DateTime updatedAt;

  SensorCalibration({
    required this.id,
    required this.sensorName,
    required this.isCalibrating,
    required this.updatedAt,
  });

  factory SensorCalibration.fromJson(Map<String, dynamic> json) {
    return SensorCalibration(
      id: json['id'],
      sensorName: json['sensor_name'] ?? '',
      isCalibrating: json['is_calibrating'] ?? false,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sensor_name': sensorName,
      'is_calibrating': isCalibrating,
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  SensorCalibration copyWith({
    int? id,
    String? sensorName,
    bool? isCalibrating,
    DateTime? updatedAt,
  }) {
    return SensorCalibration(
      id: id ?? this.id,
      sensorName: sensorName ?? this.sensorName,
      isCalibrating: isCalibrating ?? this.isCalibrating,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
