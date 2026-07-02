class SystemConfig {
  final int? id;
  final String tankName;
  final double waterVolumeLiters;
  final String macroBrandName;
  final double macroNPct;
  final double macroPPct;
  final double macroKPct;
  final String microBrandName;
  final double microNPct;
  final double microPPct;
  final double microKPct;
  final double targetMacroDosageMlL;
  final double targetMicroDosageMlL;
  final bool isActive;
  final int uploadIntervalSeconds;
  final double macroDensity;
  final double microDensity;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SystemConfig({
    this.id,
    required this.tankName,
    required this.waterVolumeLiters,
    required this.macroBrandName,
    required this.macroNPct,
    required this.macroPPct,
    required this.macroKPct,
    required this.microBrandName,
    required this.microNPct,
    required this.microPPct,
    required this.microKPct,
    required this.targetMacroDosageMlL,
    required this.targetMicroDosageMlL,
    this.macroDensity = 1.0,
    this.microDensity = 1.0,
    this.isActive = true,
    this.uploadIntervalSeconds = 60,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'tank_name': tankName,
      'water_volume_liters': waterVolumeLiters,
      'macro_brand_name': macroBrandName,
      'macro_n_pct': macroNPct,
      'macro_p_pct': macroPPct,
      'macro_k_pct': macroKPct,
      'macro_density': macroDensity,
      'micro_brand_name': microBrandName,
      'micro_n_pct': microNPct,
      'micro_p_pct': microPPct,
      'micro_k_pct': microKPct,
      'micro_density': microDensity,
      'target_macro_dosage_mll': targetMacroDosageMlL,
      'target_micro_dosage_mll': targetMicroDosageMlL,
      'is_active': isActive,
      'upload_interval_seconds': uploadIntervalSeconds,
    };
  }

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      id: json['id'],
      tankName: json['tank_name'] ?? '',
      waterVolumeLiters: (json['water_volume_liters'] as num?)?.toDouble() ?? 0.0,
      macroBrandName: json['macro_brand_name'] ?? '',
      macroNPct: (json['macro_n_pct'] as num?)?.toDouble() ?? 0.0,
      macroPPct: (json['macro_p_pct'] as num?)?.toDouble() ?? 0.0,
      macroKPct: (json['macro_k_pct'] as num?)?.toDouble() ?? 0.0,
      macroDensity: (json['macro_density'] as num?)?.toDouble() ?? 1.0,
      microBrandName: json['micro_brand_name'] ?? '',
      microNPct: (json['micro_n_pct'] as num?)?.toDouble() ?? 0.0,
      microPPct: (json['micro_p_pct'] as num?)?.toDouble() ?? 0.0,
      microKPct: (json['micro_k_pct'] as num?)?.toDouble() ?? 0.0,
      microDensity: (json['micro_density'] as num?)?.toDouble() ?? 1.0,
      targetMacroDosageMlL: (json['target_macro_dosage_mll'] as num?)?.toDouble() ?? 0.0,
      targetMicroDosageMlL: (json['target_micro_dosage_mll'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] ?? true,
      uploadIntervalSeconds: json['upload_interval_seconds'] ?? 60,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
