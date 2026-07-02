import 'package:leaf_cloud/core/constants.dart';

class TelemetryData {
  final double ph;
  final double ec;
  final double waterTemp;
  final String status;

  TelemetryData({
    required this.ph,
    required this.ec,
    required this.waterTemp,
    required this.status,
  });

  factory TelemetryData.fromJson(Map<String, dynamic> json) {
    return TelemetryData(
      ph: (json['ph'] as num).toDouble(),
      ec: (json['ec'] as num).toDouble(),
      waterTemp: (json['water_temp'] as num).toDouble(),
      status: json['status'],
    );
  }
}

class NutrientEstimation {
  final double nPpm;
  final double pPpm;
  final double kPpm;
  final double totalEstimatedPpm;
  final String unit;

  NutrientEstimation({
    required this.nPpm,
    required this.pPpm,
    required this.kPpm,
    required this.totalEstimatedPpm,
    this.unit = 'ppm',
  });

  factory NutrientEstimation.fromJson(Map<String, dynamic> json) {
    return NutrientEstimation(
      nPpm: (json['n_ppm'] as num?)?.toDouble() ?? 0.0,
      pPpm: (json['p_ppm'] as num?)?.toDouble() ?? 0.0,
      kPpm: (json['k_ppm'] as num?)?.toDouble() ?? 0.0,
      totalEstimatedPpm: (json['total_estimated_ppm'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'ppm',
    );
  }
}

class AdvisoryInsight {
  final String summary;
  final String explanation;
  final String farmerAction;

  AdvisoryInsight({
    required this.summary,
    required this.explanation,
    required this.farmerAction,
  });

  factory AdvisoryInsight.fromJson(Map<String, dynamic> json) {
    return AdvisoryInsight(
      summary: json['summary'],
      explanation: json['explanation'],
      farmerAction: json['farmer_action'],
    );
  }
}

class ActionableAlert {
  final String level;
  final String message;
  final bool actionRequired;
  final double topupMacroMl;
  final double topupMicroMl;

  ActionableAlert({
    required this.level,
    required this.message,
    required this.actionRequired,
    required this.topupMacroMl,
    required this.topupMicroMl,
  });

  factory ActionableAlert.fromJson(Map<String, dynamic> json) {
    return ActionableAlert(
      level: json['level'],
      message: json['message'],
      actionRequired: json['action_required'],
      topupMacroMl: (json['topup_macro_ml'] as num).toDouble(),
      topupMicroMl: (json['topup_micro_ml'] as num).toDouble(),
    );
  }
}

class DashboardData {
  final int tankId;
  final String tankName;
  final DateTime lastUpdated;
  final String imageUrl;
  final String healthStatus;
  final String profileDetected;
  final String predictedClass;
  final bool isAnomaly;
  final TelemetryData telemetry;
  final NutrientEstimation estimatedNutrients;
  final AdvisoryInsight? advisory;
  final ActionableAlert? alert;

  DashboardData({
    required this.tankId,
    required this.tankName,
    required this.lastUpdated,
    required this.imageUrl,
    required this.healthStatus,
    required this.profileDetected,
    required this.predictedClass,
    required this.isAnomaly,
    required this.telemetry,
    required this.estimatedNutrients,
    this.advisory,
    this.alert,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final imageUrl = ApiConstants.normalizeImageUrl(json['image_url']);

    return DashboardData(
      tankId: json['tank_id'],
      tankName: json['tank_name'],
      lastUpdated: DateTime.parse(json['last_updated']),
      imageUrl: imageUrl,
      healthStatus: json['health_status'],
      profileDetected: json['profile_detected'] ?? '',
      predictedClass: json['predicted_class'] ?? '',
      isAnomaly: json['is_anomaly'] ?? false,
      telemetry: TelemetryData.fromJson(json['telemetry']),
      estimatedNutrients: NutrientEstimation.fromJson(json['estimated_nutrients']),
      advisory: json['advisory'] != null ? AdvisoryInsight.fromJson(json['advisory']) : null,
      alert: json['alert'] != null ? ActionableAlert.fromJson(json['alert']) : null,
    );
  }
}
