import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> checkHealth(String ip, String port) async {
    final baseUrl = getBaseUrl(ip, port);
    try {
      // Try /health first, then fallback to root / if it fails with 404
      var response = await client.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) return true;
      
      if (response.statusCode == 404) {
        response = await client.get(Uri.parse('$baseUrl/')).timeout(const Duration(seconds: 5));
        return response.statusCode == 200;
      }
      return false;
    } catch (e) {
      return false;
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
