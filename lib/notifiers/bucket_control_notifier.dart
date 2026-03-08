import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class BucketControlNotifier extends ChangeNotifier {
  final ApiService apiService;

  String _activeBucketStatus = 'None';
  String? _activeExperimentId;
  String? _sendingLabel;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;

  BucketControlNotifier({required this.apiService});

  String get activeBucketStatus => _activeBucketStatus;
  String? get activeExperimentId => _activeExperimentId;
  String? get sendingLabel => _sendingLabel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> setActiveBucket(String label) async {
    _isLoading = true;
    _sendingLabel = label;
    _errorMessage = null;
    notifyListeners();

    try {
      await apiService.postActiveBucket(label);
      await fetchActiveBucketStatus(); // Refresh status immediately
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _sendingLabel = null;
      notifyListeners();
    }
  }

  Future<void> setExperimentId(String experimentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await apiService.postActiveExperiment(experimentId);
      _activeExperimentId = experimentId;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchActiveBucketStatus() async {
    try {
      _activeBucketStatus = await apiService.fetchActiveBucketStatus();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  void startPolling({Duration interval = const Duration(seconds: 2)}) {
    _timer?.cancel();
    fetchActiveBucketStatus(); // Fetch immediately
    _timer = Timer.periodic(interval, (timer) {
      fetchActiveBucketStatus();
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
