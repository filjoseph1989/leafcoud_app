class LiveTelemetryData {
  final int tankId;
  final double? ph;
  final double? ec;
  final double? waterTemp;
  final DateTime updatedAt;

  LiveTelemetryData({
    required this.tankId,
    this.ph,
    this.ec,
    this.waterTemp,
    required this.updatedAt,
  });

  factory LiveTelemetryData.fromJson(Map<String, dynamic> json) {
    return LiveTelemetryData(
      tankId: json['tank_id'],
      ph: json['ph'] != null ? (json['ph'] as num).toDouble() : null,
      ec: json['ec'] != null ? (json['ec'] as num).toDouble() : null,
      waterTemp: json['water_temp'] != null ? (json['water_temp'] as num).toDouble() : null,
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
