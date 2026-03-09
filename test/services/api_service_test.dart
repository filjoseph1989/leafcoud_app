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
              'timestamp': '2026-03-01T10:00:00Z',
              'sensors': {'temp_c': 25.0},
              'status': 'ok'
            }),
            200);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');
      final data = await apiService.fetchSensorData();

      expect(data, isA<SensorData>());
      expect(data.sensors!['temp_c'], 25.0);
    });

    test('fetchSensorData returns empty SensorData if the API returns an error key with 200 OK', () async {
      final client = MockClient((request) async {
        return http.Response(
            jsonEncode({'error': 'No data available yet'}),
            200);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');
      final data = await apiService.fetchSensorData();

      expect(data, isA<SensorData>());
      expect(data.isNoData, isTrue);
      expect(data.healthStatus, 'No Data Yet');
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
