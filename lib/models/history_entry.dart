class HistoryEntry {
  final DateTime timestamp;
  final double? n;
  final double? p;
  final double? k;
  final double? nPpm;
  final double? pPpm;
  final double? kPpm;
  final double? ec;
  final double? ph;
  final double? temp;
  final double? waterTemp;
  final String? imageUrl;
  final Map<String, dynamic> rawData;

  HistoryEntry({
    required this.timestamp,
    this.n,
    this.p,
    this.k,
    this.nPpm,
    this.pPpm,
    this.kPpm,
    this.ec,
    this.ph,
    this.temp,
    this.waterTemp,
    this.imageUrl,
    required this.rawData,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'].toString()) 
          : DateTime.now(),
      n: _toDouble(json['n']),
      p: _toDouble(json['p']),
      k: _toDouble(json['k']),
      nPpm: _toDouble(json['n_ppm']),
      pPpm: _toDouble(json['p_ppm']),
      kPpm: _toDouble(json['k_ppm']),
      ec: _toDouble(json['ec']),
      ph: _toDouble(json['ph']),
      temp: _toDouble(json['temp'] ?? json['temp_c']),
      waterTemp: _toDouble(json['water_temp']),
      imageUrl: json['image_url']?.toString(),
      rawData: json,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  double? get nitrogen => n ?? nPpm;
  double? get phosphorus => p ?? pPpm;
  double? get potassium => k ?? kPpm;
  double? get displayTemp => waterTemp ?? temp;
}
