import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_leafcloud_app/history_screen.dart';
import 'package:flutter_leafcloud_app/alerts_screen.dart';
import 'package:flutter_leafcloud_app/widgets/video_feed_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Updated endpoint per Phase 2 Spec (AppBuilding.pdf)
      // Note: Using 127.0.0.1. For Android Emulator use 10.0.2.2
      final response = await http.get(Uri.parse('http://192.168.1.7:8000/app/latest_status/'));
      
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load data: ${response.statusCode}';
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
        title: const Text('LeafCloud Dashboard'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : RefreshIndicator(
                  onRefresh: fetchData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildRecommendationCard(),
                        const SizedBox(height: 24),
                        _buildStatusCard(),
                        const SizedBox(height: 24),
                        _buildSensorReadings(),
                        const SizedBox(height: 24),
                        _buildNutrientPredictions(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildHeader() {
    const String videoUrl = 'http://192.168.1.7:8000/video_feed';
    
    String formattedDate = 'Unknown';
    if (data!['timestamp'] != null) {
      try {
        final DateTime parsedDate = DateTime.parse(data!['timestamp']);
        formattedDate = DateFormat.yMMMd().add_jm().format(parsedDate);
      } catch (e) {
        formattedDate = data!['timestamp'];
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Monitor',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: $formattedDate',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        const SizedBox(
          height: 200,
          width: double.infinity,
          child: VideoFeedWidget(url: videoUrl),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(String message) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.eco, size: 80, color: Colors.green),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: Colors.green)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    final recommendation = data?['recommendation'] as String? ?? 'No recommendation available';
    final statusData = data?['status'];
    Color color = Colors.orange;

    if (statusData is String && statusData == "Optimal") {
      color = Colors.green;
    } else if (statusData is Map && statusData['overall_status'] == "Optimal") {
      color = Colors.green;
    }

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: color),
                const SizedBox(width: 8),
                Text(
                  'Recommendation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              recommendation,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final statusData = data?['status'];
    String statusText = "Unknown";
    bool isOptimal = false;

    if (statusData is String) {
      statusText = statusData;
      isOptimal = statusText == "Optimal";
    } else if (statusData is Map) {
      statusText = statusData['overall_status']?.toString() ?? "Unknown";
      isOptimal = statusText == "Optimal";
    }
    
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: isOptimal ? Colors.green[50] : Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              isOptimal ? Icons.check_circle : Icons.warning,
              color: isOptimal ? Colors.green : Colors.orange,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Status',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 20, 
                      color: isOptimal ? Colors.green[800] : Colors.orange[800],
                      fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorReadings() {
    final sensors = data?['sensors'] as Map<String, dynamic>?;
    if (sensors == null) return const SizedBox.shrink();

    return _buildInfoCard(
      title: 'Live Sensor Data',
      icon: Icons.sensors,
      children: [
        _buildInfoRow('EC', '${sensors['ec'] ?? 'N/A'} mS/cm'),
        _buildInfoRow('pH', '${sensors['ph'] ?? 'N/A'}'),
        _buildInfoRow('Temperature', '${sensors['temp_c'] ?? sensors['temp'] ?? 'N/A'} °C'),
      ],
    );
  }

  Widget _buildNutrientPredictions() {
    // Check for 'predictions' (documented) or 'npk_levels' (legacy)
    final levels = (data?['predictions'] ?? data?['npk_levels']) as Map<String, dynamic>?;
    if (levels == null) return const SizedBox.shrink();

    return _buildInfoCard(
      title: 'NPK Predictions (ppm)',
      icon: Icons.science,
      children: [
        _buildInfoRow('Nitrogen (N)', '${levels['n_ppm'] ?? levels['Nitrogen'] ?? 'N/A'}'),
        _buildInfoRow('Phosphorus (P)', '${levels['p_ppm'] ?? levels['Phosphorus'] ?? 'N/A'}'),
        _buildInfoRow('Potassium (K)', '${levels['k_ppm'] ?? levels['Potassium'] ?? 'N/A'}'),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.green[700]),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        const Divider(height: 20, thickness: 1),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
