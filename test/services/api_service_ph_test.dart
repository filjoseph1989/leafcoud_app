import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

void main() {
  group('ApiService - pH Control', () {
    const baseUrl = 'http://test.com';

    test('requestPHUpdate completes successfully when POST /control/request-ph-update returns 200', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == '$baseUrl/control/request-ph-update' && request.method == 'POST') {
          return http.Response('{"status": "ok"}', 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      await expectLater(apiService.requestPHUpdate(), completes);
    });

    test('requestPHUpdate throws exception when POST /control/request-ph-update fails', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      await expectLater(apiService.requestPHUpdate(), throwsException);
    });

    test('acknowledgePHUpdate completes successfully when POST /control/acknowledge-ph-update returns 200', () async {
      final client = MockClient((request) async {
        if (request.url.toString() == '$baseUrl/control/acknowledge-ph-update' && request.method == 'POST') {
          return http.Response('{"status": "ok"}', 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      await expectLater(apiService.acknowledgePHUpdate(), completes);
    });

    test('acknowledgePHUpdate throws exception when POST /control/acknowledge-ph-update fails', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      await expectLater(apiService.acknowledgePHUpdate(), throwsException);
    });
  });
}
