import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/calibration_model.dart';
import 'package:leaf_cloud/repositories/calibration_repository_interface.dart';

class CalibrationProvider extends ChangeNotifier {
  final ICalibrationRepository _calibrationRepository;

  CalibrationProvider(this._calibrationRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SensorCalibration> _calibrations = [];
  List<SensorCalibration> get calibrations => _calibrations;

  Future<void> fetchCalibrations({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      _calibrations = await _calibrationRepository.getCalibrations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (showLoading) {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleCalibration(int id, bool isCalibrating) async {
    final index = _calibrations.indexWhere((c) => c.id == id);
    if (index == -1) return false;

    final oldCalibration = _calibrations[index];
    
    // Optimistic UI update
    _calibrations[index] = oldCalibration.copyWith(
      isCalibrating: isCalibrating,
      updatedAt: DateTime.now(),
    );
    notifyListeners();

    try {
      final updated = await _calibrationRepository.updateCalibration(id, isCalibrating);
      _calibrations[index] = updated;
      notifyListeners();
      return true;
    } catch (e) {
      // Revert if error
      _calibrations[index] = oldCalibration;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
