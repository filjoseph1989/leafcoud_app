import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

void main() {
  group('ApiService.restartIot', () {
    test('restartIot returns successfully on 200 OK', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), 'http://test.com/control/restart-iot');
        return http.Response('', 200);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');
      
      // This should fail initially because restartIot() is not implemented
      await expectLater(apiService.restartIot(), completes);
    });

    test('restartIot throws exception on non-200 status code', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');

      expect(apiService.restartIot(), throwsException);
    });
  });
}
