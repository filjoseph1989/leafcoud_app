import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/calibration_model.dart';
import 'package:leaf_cloud/repositories/calibration_repository_interface.dart';

class CalibrationRepository implements ICalibrationRepository {
  final http.Client _client;

  CalibrationRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (ApiConstants.token != null) {
      headers['Authorization'] = 'Bearer ${ApiConstants.token}';
    }
    return headers;
  }

  @override
  Future<List<SensorCalibration>> getCalibrations() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/calibration/'),
        headers: _getHeaders(),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SensorCalibration.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception("Access Denied: You do not have permission to perform this action. Please contact your administrator.");
      } else {
        throw Exception('Failed to load calibrations (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<SensorCalibration> updateCalibration(int id, bool isCalibrating) async {
    try {
      final response = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/calibration/$id'),
        headers: _getHeaders(),
        body: jsonEncode({'is_calibrating': isCalibrating}),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      if (response.statusCode == 200) {
        return SensorCalibration.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception("Access Denied: You do not have permission to perform this action. Please contact your administrator.");
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Failed to update calibration (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
