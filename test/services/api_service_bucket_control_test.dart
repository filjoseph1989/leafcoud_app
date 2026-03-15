import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:flutter_leafcloud_app/services/api_service.dart';

void main() {
  group('ApiService Bucket Control', () {
    const baseUrl = 'http://192.168.1.2:8000';

    test('postActiveBucket sends a POST request with the correct label', () async {
      final client = MockClient((request) async {
        if (request.method == 'POST' &&
            request.url.toString() == '$baseUrl/control/active-bucket' &&
            jsonDecode(request.body)['bucket_id'] == 'NPK') {
          return http.Response(jsonEncode({'status': 'success'}), 200);
        }
        return http.Response('Error', 400);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);
      
      // This should not throw an exception
      await apiService.postActiveBucket('NPK');
    });

    test('fetchActiveBucketStatus returns the active bucket name and ph_update_requested', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.toString() == '$baseUrl/control/current-status') {
          return http.Response(jsonEncode({
            'active_bucket_id': 'NPK',
            'ph_update_requested': true,
          }), 200);
        }
        return http.Response('Error', 400);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);
      final status = await apiService.fetchActiveBucketStatus();

      expect(status['bucket_id'], 'NPK');
      expect(status['ph_update_requested'], isTrue);
    });

    test('postActiveBucket throws an exception on error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      expect(apiService.postActiveBucket('NPK'), throwsException);
    });

    test('fetchActiveBucketStatus throws an exception on error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      expect(apiService.fetchActiveBucketStatus(), throwsException);
    });
  });
}
