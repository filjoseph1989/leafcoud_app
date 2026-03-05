import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';

void main() {
  group('ApiService Image Management', () {
    const baseUrl = 'http://192.168.1.7:8000';

    test('fetchImages returns a list of ImageInfo on success', () async {
      final client = MockClient((request) async {
        if (request.method == 'GET' &&
            request.url.toString() == '$baseUrl/admin/images/?skip=0&limit=50') {
          return http.Response(
            jsonEncode([
              {
                "filename": "test.jpg",
                "reading_id": 1,
                "timestamp": "2026-03-05T23:47:27",
                "bucket_label": "NPK",
                "image_url": "/images/test.jpg",
                "is_orphaned": false
              }
            ]),
            200,
          );
        }
        return http.Response('Not Found', 404);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);
      final images = await apiService.fetchImages();

      expect(images.length, 1);
      expect(images[0].filename, 'test.jpg');
      expect(images[0].bucketLabel, 'NPK');
    });

    test('deleteImage sends a DELETE request with Auth header and succeeds', () async {
      final client = MockClient((request) async {
        if (request.method == 'DELETE' &&
            request.url.toString() == '$baseUrl/admin/images/test.jpg' &&
            request.headers['Authorization'] == 'demo-access-token-xyz-789') {
          return http.Response('', 204);
        }
        return http.Response('Error', 400);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);
      
      // Should not throw
      await apiService.deleteImage('test.jpg');
    });

    test('fetchImages throws an exception on error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      expect(apiService.fetchImages(), throwsException);
    });

    test('deleteImage throws an exception on error', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiService(client: client, baseUrl: baseUrl);

      expect(apiService.deleteImage('test.jpg'), throwsException);
    });
  });
}
