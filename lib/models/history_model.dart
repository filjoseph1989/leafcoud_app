import 'package:leaf_cloud/core/constants.dart';

class HistoryReading {
  final int readingId;
  final DateTime timestamp;
  final String imageUrl;
  final double ph;
  final double ec;
  final double waterTemp;
  final double? predictedN;
  final double? predictedP;
  final double? predictedK;
  final double? macroScale;
  final double? microScale;

  HistoryReading({
    required this.readingId,
    required this.timestamp,
    required this.imageUrl,
    required this.ph,
    required this.ec,
    required this.waterTemp,
    this.predictedN,
    this.predictedP,
    this.predictedK,
    this.macroScale,
    this.microScale,
  });

  bool get hasAiData => predictedN != null;

  factory HistoryReading.fromJson(Map<String, dynamic> json) {
    return HistoryReading(
      readingId: json['reading_id'],
      timestamp: DateTime.parse(json['timestamp']),
      imageUrl: ApiConstants.normalizeImageUrl(json['image_url']),
      ph: (json['ph'] as num).toDouble(),
      ec: (json['ec'] as num).toDouble(),
      waterTemp: (json['water_temp'] as num).toDouble(),
      predictedN: json['predicted_n'] != null ? (json['predicted_n'] as num).toDouble() : null,
      predictedP: json['predicted_p'] != null ? (json['predicted_p'] as num).toDouble() : null,
      predictedK: json['predicted_k'] != null ? (json['predicted_k'] as num).toDouble() : null,
      macroScale: json['macro_scale'] != null ? (json['macro_scale'] as num).toDouble() : null,
      microScale: json['micro_scale'] != null ? (json['micro_scale'] as num).toDouble() : null,
    );
  }
}

class HistoryData {
  final int tankId;
  final String tankName;
  final int days;
  final int total;
  final List<HistoryReading> readings;

  HistoryData({
    required this.tankId,
    required this.tankName,
    required this.days,
    required this.total,
    required this.readings,
  });

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    return HistoryData(
      tankId: json['tank_id'],
      tankName: json['tank_name'],
      days: json['days'],
      total: json['total'],
      readings: (json['readings'] as List)
          .map((r) => HistoryReading.fromJson(r))
          .toList(),
    );
  }
}
