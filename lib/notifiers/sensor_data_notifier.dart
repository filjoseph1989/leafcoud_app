import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class SensorDataNotifier extends ChangeNotifier {
  final ApiService apiService;
  
  SensorData? _data;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;

  SensorData? get data => _data;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SensorDataNotifier({required this.apiService});

  Future<void> fetchSensorData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await apiService.fetchSensorData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 10)}) {
    _timer?.cancel();
    fetchSensorData(); // Fetch immediately
    _timer = Timer.periodic(interval, (timer) {
      fetchSensorData();
    });
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
