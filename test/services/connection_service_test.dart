import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_leafcloud_app/services/connection_service.dart';

void main() {
  group('ConnectionService', () {
    late ConnectionService connectionService;
    late MockClient mockClient;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('getSavedIp returns null when no IP is saved', () async {
      connectionService = ConnectionService(client: http.Client());
      expect(await connectionService.getSavedIp(), isNull);
    });

    test('getSavedPort returns null when no Port is saved', () async {
      connectionService = ConnectionService(client: http.Client());
      expect(await connectionService.getSavedPort(), isNull);
    });

    test('saveConnectionSettings stores IP and Port', () async {
      connectionService = ConnectionService(client: http.Client());
      await connectionService.saveConnectionSettings('192.168.1.10', '8080');

      expect(await connectionService.getSavedIp(), '192.168.1.10');
      expect(await connectionService.getSavedPort(), '8080');
    });

    test('checkHealth returns true when /health responds with 200', () async {
      mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response('{"status": "ok"}', 200);
        }
        return http.Response('Not Found', 404);
      });

      connectionService = ConnectionService(client: mockClient);
      final result = await connectionService.checkHealth('1.2.3.4', '80');

      expect(result, isTrue);
    });

    test('checkHealth returns true when /health is 404 but root / responds with 200', () async {
      mockClient = MockClient((request) async {
        if (request.url.path == '/health') {
          return http.Response('Not Found', 404);
        }
        if (request.url.path == '/') {
          return http.Response('OK', 200);
        }
        return http.Response('Error', 500);
      });

      connectionService = ConnectionService(client: mockClient);
      final result = await connectionService.checkHealth('1.2.3.4', '80');

      expect(result, isTrue);
    });

    test('checkHealth returns false when server responds with error on both /health and /', () async {
      mockClient = MockClient((request) async {
        return http.Response('Error', 500);
      });

      connectionService = ConnectionService(client: mockClient);
      final result = await connectionService.checkHealth('1.2.3.4', '80');

      expect(result, isFalse);
    });

    test('checkHealth returns false when connection fails', () async {
      mockClient = MockClient((request) async {
        throw Exception('Connection failed');
      });

      connectionService = ConnectionService(client: mockClient);
      final result = await connectionService.checkHealth('1.2.3.4', '80');

      expect(result, isFalse);
    });

    test('getBaseUrl returns default when nothing is saved', () async {
      connectionService = ConnectionService(client: http.Client());
      expect(connectionService.getBaseUrl(null, null), ConnectionService.defaultBaseUrl);
      expect(ConnectionService.defaultBaseUrl, 'http://192.168.1.7:8000');
    });

    test('getBaseUrl returns formatted URL when IP and Port are provided', () async {
      connectionService = ConnectionService(client: http.Client());
      expect(connectionService.getBaseUrl('192.168.1.10', '8080'), 'http://192.168.1.10:8080');
    });
  });
}
