import 'package:flutter/material.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class HistoryNotifier extends ChangeNotifier {
  final ApiService apiService;

  String? _experimentId;
  List<dynamic> _bucketData = [];
  bool _isLoading = false;
  String? _errorMessage;

  HistoryNotifier({required this.apiService});

  String? get experimentId => _experimentId;
  List<dynamic> get bucketData => _bucketData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHistory([String? experimentId]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.fetchExperimentHistory(experimentId);
      _experimentId = response['experiment_id']?.toString();
      _bucketData = response['bucket_data'] as List<dynamic>? ?? [];
    } catch (e) {
      _errorMessage = e.toString();
      _experimentId = null;
      _bucketData = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
