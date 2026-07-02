import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:leaf_cloud/core/constants.dart';
import 'package:leaf_cloud/models/user_model.dart';
import 'package:leaf_cloud/repositories/auth_repository_interface.dart';

class AuthRepository implements IAuthRepository {
  final http.Client _client;

  AuthRepository({http.Client? client}) : _client = client ?? http.Client();

  @override
  Future<LoginResponse> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      // Check if the response is JSON
      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server returned a non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(data);
      } else {
        String errorMessage = 'Login failed (${response.statusCode})';
        if (data is Map && data.containsKey('detail')) {
          if (data['detail'] is List) {
            errorMessage = data['detail'][0]['msg'] ?? errorMessage;
          } else {
            errorMessage = data['detail'].toString();
          }
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<User> register(String name, String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server returned a non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return User.fromJson(data);
      } else {
        String errorMessage = 'Registration failed (${response.statusCode})';
        if (data is Map && data.containsKey('detail')) {
          if (data['detail'] is List) {
            errorMessage = data['detail'][0]['msg'] ?? errorMessage;
          } else {
            errorMessage = data['detail'].toString();
          }
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout(String accessToken, String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (response.statusCode != 200) {
        throw Exception('Logout on server failed (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred during logout: $e');
    }
  }

  @override
  Future<LoginResponse> refresh(String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server error: Non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginResponse.fromJson(data);
      } else {
        throw Exception(data['detail'] ?? 'Token refresh failed (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred during refresh: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final contentType = response.headers['content-type'];
      final data = (contentType != null && contentType.contains('application/json'))
          ? jsonDecode(response.body)
          : null;

      if (response.statusCode != 200) {
        String errorMessage = 'Forgot password request failed (${response.statusCode})';
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': token,
          'new_password': newPassword,
        }),
      );

      final contentType = response.headers['content-type'];
      final data = (contentType != null && contentType.contains('application/json'))
          ? jsonDecode(response.body)
          : null;

      if (response.statusCode != 200) {
        String errorMessage = 'Reset password failed (${response.statusCode})';
        if (data is Map && data.containsKey('detail')) {
          errorMessage = data['detail'].toString();
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }

  @override
  Future<User> updateProfile(
    String accessToken, {
    String? name,
    String? email,
    String? currentPassword,
    String? newPassword,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (email != null) payload['email'] = email;
      if (currentPassword != null) payload['current_password'] = currentPassword;
      if (newPassword != null) payload['new_password'] = newPassword;

      final response = await _client.patch(
        Uri.parse('${ApiConstants.baseUrl}/api/v1/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      final contentType = response.headers['content-type'];
      if (contentType == null || !contentType.contains('application/json')) {
        throw Exception('Server returned a non-JSON response (Status: ${response.statusCode})');
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return User.fromJson(data);
      } else {
        String errorMessage = 'Profile update failed (${response.statusCode})';
        if (data is Map && data.containsKey('detail')) {
          if (data['detail'] is List) {
            errorMessage = data['detail'][0]['msg'] ?? errorMessage;
          } else {
            errorMessage = data['detail'].toString();
          }
        } else if (data is Map && data.containsKey('message')) {
          errorMessage = data['message'];
        }
        throw Exception(errorMessage);
      }
    } on FormatException {
      throw Exception('Server error: Invalid data format received.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('An unexpected error occurred: $e');
    }
  }
}

