class AlertStatus {
  final int tankId;
  final String tankName;
  final bool hasAlert;
  final String? level;
  final String? message;
  final double? topupMacroMl;
  final double? topupMicroMl;
  final DateTime lastReadingAt;

  AlertStatus({
    required this.tankId,
    required this.tankName,
    required this.hasAlert,
    this.level,
    this.message,
    this.topupMacroMl,
    this.topupMicroMl,
    required this.lastReadingAt,
  });

  factory AlertStatus.fromJson(Map<String, dynamic> json) {
    return AlertStatus(
      tankId: json['tank_id'],
      tankName: json['tank_name'],
      hasAlert: json['has_alert'],
      level: json['level'],
      message: json['message'],
      topupMacroMl: json['topup_macro_ml']?.toDouble(),
      topupMicroMl: json['topup_micro_ml']?.toDouble(),
      lastReadingAt: DateTime.parse(json['last_reading_at']),
    );
  }
}
