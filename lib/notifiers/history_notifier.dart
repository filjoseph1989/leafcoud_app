import 'package:flutter/material.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/history_entry.dart';

class HistoryNotifier extends ChangeNotifier {
  final ApiService apiService;

  String? _experimentId;
  Map<String, List<HistoryEntry>> _historyData = {};
  String? _selectedBucket;
  bool _isLoading = false;
  String? _errorMessage;

  HistoryNotifier({required this.apiService});

  String? get experimentId => _experimentId;
  Map<String, List<HistoryEntry>> get historyData => _historyData;
  List<String> get availableBuckets => _historyData.keys.toList();
  String? get selectedBucket => _selectedBucket;
  
  List<HistoryEntry> get currentBucketData {
    if (_selectedBucket != null && _historyData.containsKey(_selectedBucket)) {
      return _historyData[_selectedBucket]!;
    }
    return [];
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void selectBucket(String bucketName) {
    if (_historyData.containsKey(bucketName)) {
      _selectedBucket = bucketName;
      notifyListeners();
    }
  }

  Future<void> fetchHistory([String? experimentId]) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.fetchExperimentHistory(experimentId);
      _experimentId = response['experiment_id']?.toString();
      
      final rawHistory = response['history'] as Map<String, dynamic>? ?? {};
      _historyData = rawHistory.map((key, value) {
        final List<dynamic> list = value as List<dynamic>? ?? [];
        return MapEntry(
          key, 
          list.map((item) => HistoryEntry.fromJson(item as Map<String, dynamic>)).toList()
        );
      });
      
      if (_historyData.isNotEmpty) {
        _selectedBucket = _historyData.keys.first;
      } else {
        _selectedBucket = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _experimentId = null;
      _historyData = {};
      _selectedBucket = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
