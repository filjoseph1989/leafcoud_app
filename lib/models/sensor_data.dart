class SensorData {
  final DateTime timestamp;
  final String? plantId;
  final String? lettuceImageUrl;
  final Map<String, dynamic>? sensors;
  final Map<String, dynamic>? predictions;
  final dynamic status; // Can be String or Map
  final String? recommendation;
  final bool phUpdateRequested;

  SensorData({
    required this.timestamp,
    this.plantId,
    this.lettuceImageUrl,
    this.sensors,
    this.predictions,
    this.status,
    this.recommendation,
    this.phUpdateRequested = false,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'].toString()) 
          : DateTime.now(),
      plantId: json['plant_id']?.toString(),
      lettuceImageUrl: json['lettuce_image_url']?.toString(),
      sensors: json['sensors'] is Map<String, dynamic> ? json['sensors'] : null,
      predictions: (json['predictions'] ?? json['npk_levels']) is Map<String, dynamic> 
          ? (json['predictions'] ?? json['npk_levels']) 
          : null,
      status: json['status'],
      recommendation: json['recommendation']?.toString(),
      phUpdateRequested: json['ph_update_requested'] == true,
    );
  }

  String get healthStatus {
    if (status is String) {
      return status as String;
    } else if (status is Map) {
      return (status as Map)['overall_status']?.toString() ?? 'No Data Yet';
    }
    return 'No Data Yet';
  }

  bool get isNoData => sensors == null && status == null;

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
