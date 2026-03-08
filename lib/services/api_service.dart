import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_leafcloud_app/models/sensor_data.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({required this.client, required this.baseUrl});

  Future<SensorData> fetchSensorData() async {
    final response = await client.get(Uri.parse('$baseUrl/app/latest_status/'));

    if (response.statusCode == 200) {
      return SensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensor data: ${response.statusCode}');
    }
  }

  Future<void> postActiveBucket(String label) async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/active-bucket'),
      headers: {'Content-Type': 'application/json'},
      // Changed key to 'bucket_id' per server documentation
      body: jsonEncode({'bucket_id': label}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set active bucket: ${response.statusCode}');
    }
  }

  Future<void> postActiveExperiment(String experimentId) async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/active-experiment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'experiment_id': experimentId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to set active experiment: ${response.statusCode}');
    }
  }

  Future<String> fetchActiveBucketStatus() async {
    // Removed trailing slash based on curl redirect results
    final response = await client.get(Uri.parse('$baseUrl/control/current-status'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Updated keys to match server response: active_bucket_id
      return data['active_bucket_id']?.toString() ?? data['bucket_id'] ?? data['active_bucket'] ?? 'None';
    } else {
      throw Exception('Failed to fetch active bucket status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchExperimentHistory(String experimentId) async {
    final response = await client.get(
      Uri.parse('$baseUrl/experiments/$experimentId/history'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load experiment history: ${response.statusCode}');
    }
  }

  Future<List<ImageInfo>> fetchImages({int skip = 0, int limit = 50}) async {
    final response = await client.get(
      Uri.parse('$baseUrl/admin/images/?skip=$skip&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ImageInfo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load images: ${response.statusCode}');
    }
  }

  Future<void> deleteImage(String filename) async {
    final response = await client.delete(
      Uri.parse('$baseUrl/admin/images/$filename'),
      headers: {
        'Authorization': 'demo-access-token-xyz-789',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete image: ${response.statusCode}');
    }
  }
}
