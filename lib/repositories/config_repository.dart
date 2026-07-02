import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/system_config_model.dart';
import 'package:leaf_cloud/repositories/config_repository_interface.dart';

class ConfigRepository implements IConfigRepository {
  final http.Client _client;

  ConfigRepository({http.Client? client}) : _client = client ?? http.Client();

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (ApiConstants.token != null) {
      headers['Authorization'] = 'Bearer ${ApiConstants.token}';
    }
    return headers;
  }

  @override
  Future<List<SystemConfig>> listConfigs() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/tank-configs/'),
        headers: _getHeaders(),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SystemConfig.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception("Access Denied: You do not have permission to perform this action. Please contact your administrator.");
      } else {
        throw Exception('Failed to list configurations (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<SystemConfig> getConfig(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/tank-configs/$id'),
        headers: _getHeaders(),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      if (response.statusCode == 200) {
        return SystemConfig.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception("Access Denied: You do not have permission to perform this action. Please contact your administrator.");
      } else {
        throw Exception('Failed to load configuration (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<SystemConfig> createConfig(SystemConfig config) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/tank-configs/'),
        headers: _getHeaders(),
        body: jsonEncode(config.toJson()),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        return SystemConfig.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception("Access Denied: You do not have permission to perform this action. Please contact your administrator.");
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Failed to create configuration (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<SystemConfig> updateConfig(int id, SystemConfig config) async {
    try {
      final response = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/tank-configs/$id'),
        headers: _getHeaders(),
        body: jsonEncode(config.toJson()),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      if (response.statusCode == 200) {
        return SystemConfig.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 403) {
        throw Exception("Access Denied: You do not have permission to perform this action. Please contact your administrator.");
      } else {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Failed to update configuration (${response.statusCode})');
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> deleteConfig(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.baseUrl}/api/v1/tank-configs/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 403) {
      throw Exception("Access Denied: You do not have permission to perform this action. Please contact your administrator.");
    }
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete configuration');
    }
  }
}
