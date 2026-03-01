class SensorData {
  final DateTime timestamp;
  final String? plantId;
  final String? lettuceImageUrl;
  final Map<String, dynamic>? sensors;
  final Map<String, dynamic>? predictions;
  final dynamic status; // Can be String or Map
  final String? recommendation;

  SensorData({
    required this.timestamp,
    this.plantId,
    this.lettuceImageUrl,
    this.sensors,
    this.predictions,
    this.status,
    this.recommendation,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: DateTime.parse(json['timestamp'] as String),
      plantId: json['plant_id'] as String?,
      lettuceImageUrl: json['lettuce_image_url'] as String?,
      sensors: json['sensors'] as Map<String, dynamic>?,
      predictions: (json['predictions'] ?? json['npk_levels']) as Map<String, dynamic>?,
      status: json['status'],
      recommendation: json['recommendation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'plant_id': plantId,
      'lettuce_image_url': lettuceImageUrl,
      'sensors': sensors,
      'predictions': predictions,
      'status': status,
      'recommendation': recommendation,
    };
  }
}
