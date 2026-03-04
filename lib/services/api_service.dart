import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

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

  Future<String> fetchActiveBucketStatus() async {
    // Changed endpoint to '/control/current-status' per server documentation
    final response = await client.get(Uri.parse('$baseUrl/control/current-status'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // We'll check for 'bucket_id' or 'active_bucket' based on typical patterns
      return data['bucket_id'] ?? data['active_bucket'] ?? 'None';
    } else {
      throw Exception('Failed to fetch active bucket status: ${response.statusCode}');
    }
  }
}
