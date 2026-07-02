import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/dashboard_model.dart';
import 'package:leaf_cloud/models/history_model.dart';
import 'package:leaf_cloud/models/telemetry_model.dart';
import 'package:leaf_cloud/repositories/iot_repository_interface.dart';

class IotProvider extends ChangeNotifier {
  final IIotRepository _iotRepository;
  Timer? _telemetryTimer;

  IotProvider(this._iotRepository);

  // --- Dashboard ---
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  DashboardData? _dashboardData;
  DashboardData? get dashboardData => _dashboardData;

  Future<void> fetchDashboard(int tankId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _iotRepository.getDashboard(tankId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- History ---
  bool _isHistoryLoading = false;
  bool get isHistoryLoading => _isHistoryLoading;

  String? _historyError;
  String? get historyError => _historyError;

  HistoryData? _historyData;
  HistoryData? get historyData => _historyData;

  Future<void> fetchHistory(int tankId, {int days = 7}) async {
    _isHistoryLoading = true;
    _historyError = null;
    notifyListeners();

    try {
      _historyData = await _iotRepository.getHistory(tankId, days: days);
      _isHistoryLoading = false;
      notifyListeners();
    } catch (e) {
      _historyError = e.toString().replaceAll('Exception: ', '');
      _isHistoryLoading = false;
      notifyListeners();
    }
  }

  // --- Live Telemetry ---
  LiveTelemetryData? _liveTelemetry;
  LiveTelemetryData? get liveTelemetry => _liveTelemetry;

  void startLiveTelemetryPolling(int tankId) {
    stopLiveTelemetryPolling(); // Cancel any existing polling
    
    // Fetch immediately, then schedule every 3 seconds
    fetchLiveTelemetry(tankId);
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      fetchLiveTelemetry(tankId);
    });
  }

  void stopLiveTelemetryPolling() {
    _telemetryTimer?.cancel();
    _telemetryTimer = null;
  }

  Future<void> fetchLiveTelemetry(int tankId) async {
    try {
      _liveTelemetry = await _iotRepository.getLiveTelemetry(tankId);
      
      // Dynamically merge live telemetry into the active dashboard model
      if (_dashboardData != null && _liveTelemetry != null) {
        _dashboardData = DashboardData(
          tankId: _dashboardData!.tankId,
          tankName: _dashboardData!.tankName,
          lastUpdated: _liveTelemetry!.updatedAt,
          imageUrl: _dashboardData!.imageUrl,
          healthStatus: _dashboardData!.healthStatus,
          profileDetected: _dashboardData!.profileDetected,
          predictedClass: _dashboardData!.predictedClass,
          isAnomaly: _dashboardData!.isAnomaly,
          telemetry: TelemetryData(
            ph: _liveTelemetry!.ph ?? _dashboardData!.telemetry.ph,
            ec: _liveTelemetry!.ec ?? _dashboardData!.telemetry.ec,
            waterTemp: _liveTelemetry!.waterTemp ?? _dashboardData!.telemetry.waterTemp,
            status: _dashboardData!.telemetry.status,
          ),
          estimatedNutrients: _dashboardData!.estimatedNutrients,
          advisory: _dashboardData!.advisory,
          alert: _dashboardData!.alert,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error polling live telemetry: $e');
    }
  }

  @override
  void dispose() {
    stopLiveTelemetryPolling();
    super.dispose();
  }
}
