import 'package:leaf_cloud/models/calibration_model.dart';

abstract class ICalibrationRepository {
  Future<List<SensorCalibration>> getCalibrations();
  Future<SensorCalibration> updateCalibration(int id, bool isCalibrating);
}
