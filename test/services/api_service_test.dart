import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

void main() {
  group('ApiService', () {
    test('fetchSensorData returns SensorData if the http call completes successfully', () async {
      final client = MockClient((request) async {
        return http.Response(
            jsonEncode({
              'temperature': 25.0,
              'ec': 1.5,
              'ph': 6.8,
              'status': 'ok',
              'timestamp': '2026-03-01T10:00:00Z'
            }),
            200);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');
      final data = await apiService.fetchSensorData();

      expect(data, isA<SensorData>());
      expect(data.temperature, 25.0);
    });

    test('fetchSensorData throws an exception if the http call completes with an error', () async {
      final client = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');

      expect(apiService.fetchSensorData(), throwsException);
    });
  });
}
