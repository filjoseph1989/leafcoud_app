import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

class ApiService {
  final http.Client client;
  final String baseUrl;

  ApiService({required this.client, required this.baseUrl});

  Future<SensorData> fetchSensorData() async {
    final response = await client.post(Uri.parse('$baseUrl/iot/sensor_data/'));

    if (response.statusCode == 200) {
      return SensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensor data');
    }
  }
}
