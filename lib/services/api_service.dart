import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_leafcloud_app/models/sensor_data.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';

class ApiService {
  final http.Client client;
  String baseUrl;

  ApiService({required this.client, required this.baseUrl});

  Future<SensorData> fetchSensorData() async {
    final response = await client.get(Uri.parse('$baseUrl/app/latest_status/'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Return SensorData even if it's empty/error-state JSON
      return SensorData.fromJson(data is Map<String, dynamic> ? data : {});
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

  Future<Map<String, dynamic>> fetchActiveBucketStatus() async {
    // Removed trailing slash based on curl redirect results
    final response = await client.get(Uri.parse('$baseUrl/control/current-status'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Updated keys to match server response: active_bucket_id
      return {
        'bucket_id': data['active_bucket_id']?.toString() ?? data['bucket_id'] ?? data['active_bucket'] ?? 'None',
        'ph_update_requested': data['ph_update_requested'] == true,
      };
    } else {
      throw Exception('Failed to fetch active bucket status: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchExperimentHistory(String? experimentId) async {
    // If experimentId is null or empty, fetch latest global history
    if (experimentId == null || experimentId.isEmpty) {
      final response = await client.get(Uri.parse('$baseUrl/app/history/'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'experiment_id': 'Latest', 'history': {'All': data}};
      }
      throw Exception('Failed to load global history: ${response.statusCode}');
    }

    // Try to fetch ID-specific history
    // Server expects integer ID for /experiments/{id}/history
    final isInteger = int.tryParse(experimentId) != null;
    final url = isInteger 
        ? '$baseUrl/experiments/$experimentId/history'
        : '$baseUrl/app/history/?experiment_id=$experimentId';

    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      } else if (decoded is List) {
        return {'experiment_id': experimentId, 'history': {'All': decoded}};
      }
      return {'experiment_id': experimentId, 'history': {}};
    } else if (response.statusCode == 404) {
      throw Exception('Experiment not found');
    } else if (response.statusCode == 422) {
      // Graceful fallback for unprocessable records
      return {'experiment_id': experimentId, 'history': {}};
    } else {
      throw Exception('Failed to load history for $experimentId: ${response.statusCode}');
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

  Future<void> restartIot() async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/restart-iot'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to restart IoT system: ${response.statusCode}');
    }
  }

  Future<void> requestPHUpdate() async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/request-ph-update'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to request pH update: ${response.statusCode}');
    }
  }

  Future<void> acknowledgePHUpdate() async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/acknowledge-ph-update'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to acknowledge pH update: ${response.statusCode}');
    }
  }

  Future<void> postCalibrateEC(double value) async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/calibrate-ec'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'value': value}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to calibrate EC: ${response.statusCode}');
    }
  }

  Future<void> postCalibratePH(double value) async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/calibrate-ph'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'value': value}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to calibrate pH: ${response.statusCode}');
    }
  }

  Future<void> postStopCalibration() async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/stop-calibration'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to stop calibration: ${response.statusCode}');
    }
  }

  Future<void> requestCalibration(String type) async {
    final response = await client.post(
      Uri.parse('$baseUrl/control/request-calibration'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'type': type}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to request $type calibration: ${response.statusCode}');
    }
  }
}
