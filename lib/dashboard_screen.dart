import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_leafcloud_app/history_screen.dart';

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
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/app/latest_status/'));
      
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Monitor',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: ${data!['timestamp'] ?? 'Unknown'}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Center(
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: Colors.green[100]!),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.eco, size: 80, color: Colors.green),
                SizedBox(height: 8),
                Text("Live Image Stream", style: TextStyle(color: Colors.green)),
                // TODO: Add image support when API includes image_url
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    final status = data!['status'] as String? ?? "Unknown";
    final isOptimal = status == "Optimal";
    final color = isOptimal ? Colors.green : Colors.orange;

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[50],
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
              data!['recommendation'] ?? 'No recommendation available',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    final status = data!['status'] as String? ?? "Unknown";
    final isOptimal = status == "Optimal";
    
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.green[50],
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
                    status,
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
    final sensors = data!['sensors'] as Map<String, dynamic>;
    return _buildInfoCard(
      title: 'Live Sensor Data',
      icon: Icons.sensors,
      children: [
        _buildInfoRow('EC', '${sensors['ec']} mS/cm'),
        _buildInfoRow('pH', '${sensors['ph']}'),
        _buildInfoRow('Temperature', '${sensors['temp']} °C'),
      ],
    );
  }

  Widget _buildNutrientPredictions() {
    final levels = data!['npk_levels'] as Map<String, dynamic>;
    return _buildInfoCard(
      title: 'NPK Predictions (ppm)',
      icon: Icons.science,
      children: [
        _buildInfoRow('Nitrogen (N)', '${levels['Nitrogen']}'),
        _buildInfoRow('Phosphorus (P)', '${levels['Phosphorus']}'),
        _buildInfoRow('Potassium (K)', '${levels['Potassium']}'),
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
