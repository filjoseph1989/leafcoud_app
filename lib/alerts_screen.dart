import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  List<Map<String, dynamic>> alerts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  Future<void> fetchAlerts() async {
    try {
      // Updated to use the new Server-Side Alerts Endpoint
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/app/alerts/?limit=50'));
      
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        setState(() {
          alerts = rawData.map((item) => item as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load alerts: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recent Alerts'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : alerts.isEmpty
                  ? const Center(child: Text('No recent alerts. Great job!'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: alerts.length,
                      itemBuilder: (context, index) {
                        final alert = alerts[index];
                        final isCritical = alert['severity'] == 'critical';
                        
                        String formattedDate = 'Unknown';
                        if (alert['timestamp'] != null) {
                          try {
                            final DateTime parsedDate = DateTime.parse(alert['timestamp']);
                            formattedDate = DateFormat.yMMMd().add_jm().format(parsedDate);
                          } catch (e) {
                            formattedDate = alert['timestamp'].toString();
                          }
                        }

                        return Card(
                          color: isCritical ? Colors.red[50] : Colors.orange[50],
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          child: ListTile(
                            leading: Icon(
                              isCritical ? Icons.error : Icons.warning,
                              color: isCritical ? Colors.red : Colors.orange,
                            ),
                            title: Text(
                              isCritical ? 'Critical Issue' : 'Warning', 
                              style: const TextStyle(fontWeight: FontWeight.bold)
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(alert['message'] ?? 'No details provided'),
                                const SizedBox(height: 4),
                                Text(formattedDate, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}