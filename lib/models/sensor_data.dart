class SensorData {
  final double temperature;
  final double ec;
  final double ph;
  final String status;
  final DateTime timestamp;

  SensorData({
    required this.temperature,
    required this.ec,
    required this.ph,
    required this.status,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] as num).toDouble(),
      ec: (json['ec'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'ec': ec,
      'ph': ph,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
