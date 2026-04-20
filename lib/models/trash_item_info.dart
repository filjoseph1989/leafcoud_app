class TrashItemInfo {
  final int id;
  final String filename;
  final String reason;
  final double metricValue;
  final DateTime timestamp;

  TrashItemInfo({
    required this.id,
    required this.filename,
    required this.reason,
    required this.metricValue,
    required this.timestamp,
  });

  factory TrashItemInfo.fromJson(Map<String, dynamic> json) {
    return TrashItemInfo(
      id: json['id'] as int,
      filename: json['filename'] as String,
      reason: json['reason'] as String,
      metricValue: (json['metric_value'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filename': filename,
      'reason': reason,
      'metric_value': metricValue,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
