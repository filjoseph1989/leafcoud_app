import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/dashboard_model.dart';
import 'package:leaf_cloud/models/history_model.dart';
import 'package:leaf_cloud/models/alert_model.dart';
import 'package:leaf_cloud/models/telemetry_model.dart';
import 'package:leaf_cloud/repositories/iot_repository_interface.dart';

class IotRepository implements IIotRepository {
  final http.Client _client;

  IotRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (ApiConstants.token != null) {
      headers['Authorization'] = 'Bearer ${ApiConstants.token}';
    }
    return headers;
  }

  @override
  Future<DashboardData> getDashboard(int tankId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/iot/dashboard/$tankId'),
        headers: _getHeaders(),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return DashboardData.fromJson(data);
      } else {
        throw Exception(data['detail'] ?? 'Failed to load dashboard (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AlertStatus> getAlertStatus(int tankId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/iot/alert/$tankId'),
        headers: _getHeaders(),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AlertStatus.fromJson(data);
      } else {
        throw Exception(data['detail'] ?? 'Failed to load alert status (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<HistoryData> getHistory(int tankId, {int days = 7, int limit = 200}) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/api/v1/iot/history/$tankId')
          .replace(queryParameters: {'days': '$days', 'limit': '$limit'});

      final response = await _client.get(uri, headers: _getHeaders());

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return HistoryData.fromJson(data);
      } else {
        throw Exception(data['detail'] ?? 'Failed to load history (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<LiveTelemetryData> getLiveTelemetry(int tankId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/iot/telemetry/$tankId'),
        headers: _getHeaders(),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LiveTelemetryData.fromJson(data);
      } else {
        throw Exception(data['detail'] ?? 'Failed to load live telemetry (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
