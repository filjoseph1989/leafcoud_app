import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HealthCheckResult {
  final bool success;
  final String? errorMessage;
  final int? statusCode;

  HealthCheckResult({required this.success, this.errorMessage, this.statusCode});
}

class ConnectionService {
  final http.Client client;
  static const String keyIp = 'server_ip';
  static const String keyPort = 'server_port';
  static const String defaultBaseUrl = 'http://192.168.1.7:8000';

  ConnectionService({required this.client});

  Future<String?> getSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyIp);
  }

  Future<String?> getSavedPort() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPort);
  }

  Future<void> saveConnectionSettings(String ip, String port) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyIp, ip);
    await prefs.setString(keyPort, port);
  }

  Future<HealthCheckResult> checkHealth(String ip, String port) async {
    final baseUrl = getBaseUrl(ip, port);
    debugPrint('ConnectionService: Checking health for $baseUrl/app/latest_status/');
    try {
      // Use /app/latest_status/ to verify server is reachable
      final response = await client.get(Uri.parse('$baseUrl/app/latest_status/')).timeout(const Duration(seconds: 5));
      debugPrint('ConnectionService: Health check response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return HealthCheckResult(success: true);
      } else {
        return HealthCheckResult(
          success: false, 
          statusCode: response.statusCode,
          errorMessage: 'Server responded with status ${response.statusCode}'
        );
      }
    } catch (e) {
      debugPrint('ConnectionService: Health check failed with error: $e');
      String message = e.toString();
      if (message.contains('SocketException')) {
        message = 'Connection failed: Host is unreachable. Ensure the server is running and on the same network.';
      } else if (message.contains('TimeoutException')) {
        message = 'Connection timed out. The server took too long to respond.';
      }
      return HealthCheckResult(success: false, errorMessage: message);
    }
  }

  String getBaseUrl(String? ip, String? port) {
    if (ip == null || ip.isEmpty) {
      return defaultBaseUrl;
    }
    if (port == null || port.isEmpty) {
      return 'http://$ip';
    }
    return 'http://$ip:$port';
  }
}
