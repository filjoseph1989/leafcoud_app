import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/trash_item_info.dart';

void main() {
  group('ApiService - Trash', () {
    test('getTrashItems returns list of TrashItemInfo on success', () async {
      final client = MockClient((request) async {
        if (request.url.path == '/api/v1/images/trash') {
          return http.Response(
            jsonEncode([
              {
                'id': 1,
                'filename': 'img1.jpg',
                'reason': 'test',
                'metric_value': 10.0,
                'timestamp': '2026-04-15T12:00:00Z'
              }
            ]),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');
      final items = await apiService.getTrashItems();

      expect(items, isA<List<TrashItemInfo>>());
      expect(items.length, 1);
      expect(items[0].filename, 'img1.jpg');
    });

    test('getTrashItems sends skip and limit parameters', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['skip'], '10');
        expect(request.url.queryParameters['limit'], '20');
        return http.Response(jsonEncode([]), 200);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');
      await apiService.getTrashItems(skip: 10, limit: 20);
    });

    test('getTrashItems throws exception on error', () async {
      final client = MockClient((request) async {
        return http.Response('Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: 'http://test.com');
      expect(apiService.getTrashItems(), throwsException);
    });
  });
}
