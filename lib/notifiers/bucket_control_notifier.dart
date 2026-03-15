import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class BucketControlNotifier extends ChangeNotifier {
  final ApiService apiService;

  String _activeBucketStatus = 'None';
  bool _phUpdateRequested = false;
  String? _activeExperimentId;
  String? _sendingLabel;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;

  BucketControlNotifier({required this.apiService});

  String get activeBucketStatus => _activeBucketStatus;
  bool get phUpdateRequested => _phUpdateRequested;
  String? get activeExperimentId => _activeExperimentId;
  String? get sendingLabel => _sendingLabel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> setActiveBucket(String label) async {
    _isLoading = true;
    _sendingLabel = label;
    _errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      await apiService.postActiveBucket(label);
      await fetchActiveBucketStatus(); // Refresh status immediately
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      _sendingLabel = null;
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> setExperimentId(String experimentId) async {
    _isLoading = true;
    _errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      await apiService.postActiveExperiment(experimentId);
      _activeExperimentId = experimentId;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> fetchActiveBucketStatus() async {
    try {
      final status = await apiService.fetchActiveBucketStatus();
      _activeBucketStatus = status['bucket_id'];
      _phUpdateRequested = status['ph_update_requested'];
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> togglePHSession() async {
    _isLoading = true;
    _errorMessage = null;
    final previousState = _phUpdateRequested;
    
    // Optimistic update
    _phUpdateRequested = !previousState;
    if (hasListeners) notifyListeners();

    try {
      if (!previousState) {
        await apiService.requestPHUpdate();
      } else {
        await apiService.acknowledgePHUpdate();
      }
      await fetchActiveBucketStatus(); // Sync with server
    } catch (e) {
      _errorMessage = e.toString();
      _phUpdateRequested = previousState; // Revert on failure
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  Future<void> stopPHSession() async {
    if (_phUpdateRequested) {
      _isLoading = true;
      if (hasListeners) notifyListeners();
      try {
        await apiService.acknowledgePHUpdate();
        await fetchActiveBucketStatus();
      } catch (e) {
        _errorMessage = e.toString();
      } finally {
        _isLoading = false;
        if (hasListeners) notifyListeners();
      }
    }
  }

  Future<void> restartIot() async {
    _isLoading = true;
    _errorMessage = null;
    if (hasListeners) notifyListeners();

    try {
      await apiService.restartIot();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
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
