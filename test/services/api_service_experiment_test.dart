import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:flutter_leafcloud_app/services/api_service.dart';

void main() {
  group('ApiService Experiment Control', () {
    const baseUrl = 'http://192.168.1.7:8000';

    test('postActiveExperiment sends a POST request with the correct experiment_id', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.toString() == '$baseUrl/control/active-experiment' &&
            jsonDecode(request.body)['experiment_id'] == 'EXP-NPK-BATCH1') {
          return http.Response(jsonEncode({'status': 'success'}), 200);
        }
        return http.Response('Error', 400);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);
      
      // Should not throw exception
      // This will fail because the method doesn't exist yet
      await apiService.postActiveExperiment('EXP-NPK-BATCH1');
    });

    test('fetchExperimentHistory returns data pre-grouped by bucket', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.toString() == '$baseUrl/experiments/1/history') {
          return http.Response(jsonEncode({
            'id': 1,
            'experiment_id': 'EXP-NPK-AUTO',
            'history': {
              'NPK': [
                {'timestamp': '2026-03-08T10:00:00Z', 'n': 100.0, 'ph': 6.0}
              ]
            }
          }), 200);
        }
        return http.Response('Error', 400);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);
      final history = await apiService.fetchExperimentHistory('1');

      expect(history, isA<Map<String, dynamic>>());
      expect(history['experiment_id'], 'EXP-NPK-AUTO');
      expect(history['history'], isA<Map<String, dynamic>>());
      expect(history['history']['NPK'], isA<List>());
    });
  });
}
