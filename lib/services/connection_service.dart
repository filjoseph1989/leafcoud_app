import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ConnectionService {
  final http.Client client;
  static const String keyIp = 'server_ip';
  static const String keyPort = 'server_port';
  static const String defaultBaseUrl = 'https://leafcloud-server.onrender.com';

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
      final response = await client.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
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
