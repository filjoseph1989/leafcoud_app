class PHSensorData {
  final DateTime timestamp;
  final int rawAdc;
  final double voltage;
  final String deviceId;

  PHSensorData({
    required this.timestamp,
    required this.rawAdc,
    required this.voltage,
    required this.deviceId,
  });

  factory PHSensorData.fromJson(Map<String, dynamic> json) {
    return PHSensorData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      rawAdc: json['raw_adc'] as int,
      voltage: (json['voltage'] as num).toDouble(),
      deviceId: json['device_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'raw_adc': rawAdc,
      'voltage': voltage,
      'device_id': deviceId,
    };
  }
}
