import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:leaf_cloud/core/constants.dart';

/// A custom HTTP client that injects authorization headers and
/// handles automatic token refresh rotation (RTR) on 401 responses.
class AuthClient extends http.BaseClient {
  final http.Client _inner;

  AuthClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // 1. Inject Authorization header if Access Token exists
    if (ApiConstants.token != null && !request.headers.containsKey('Authorization')) {
      request.headers['Authorization'] = 'Bearer ${ApiConstants.token}';
    }
    
    // Inject standard JSON headers
    if (!request.headers.containsKey('Content-Type')) {
      request.headers['Content-Type'] = 'application/json';
    }

    // 2. Send the request
    final response = await _inner.send(request);

    // 3. Intercept 401 and attempt automatic token refresh
    if (response.statusCode == 401 && ApiConstants.refreshToken != null) {
      final path = request.url.path;
      // Prevent recursive loop on auth endpoints
      if (path.contains('/auth/refresh') || path.contains('/auth/login') || path.contains('/auth/register')) {
        return response;
      }

      final success = await _performTokenRefresh();
      if (success) {
        // Recreate request since requests can only be sent once in http package
        final retryRequest = _copyRequest(request);
        if (ApiConstants.token != null) {
          retryRequest.headers['Authorization'] = 'Bearer ${ApiConstants.token}';
        }
        return await _inner.send(retryRequest);
      }
    }

    return response;
  }

  Future<bool> _performTokenRefresh() async {
    try {
      final response = await _inner.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': ApiConstants.refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        ApiConstants.token = data['token'];
        ApiConstants.refreshToken = data['refresh_token'];
        debugPrint('Token refreshed successfully via RTR.');
        return true;
      } else {
        // Refresh token expired or blacklisted, clear session
        ApiConstants.token = null;
        ApiConstants.refreshToken = null;
        debugPrint('Token refresh failed: session expired.');
        return false;
      }
    } catch (e) {
      debugPrint('Error performing token refresh: $e');
      return false;
    }
  }

  http.BaseRequest _copyRequest(http.BaseRequest request) {
    if (request is http.Request) {
      final copy = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..maxRedirects = request.maxRedirects
        ..followRedirects = request.followRedirects
        ..persistentConnection = request.persistentConnection
        ..bodyBytes = request.bodyBytes;
      return copy;
    }
    return request;
  }
}
