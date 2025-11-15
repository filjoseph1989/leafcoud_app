import 'package:flutter/material.dart';
import 'package:flutter_leafcloud_app/history_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Map<String, dynamic> data = {
    "timestamp": "2025-11-16T10:30:01Z",
    "plant_id": "bucket_1_lettuce",
    "lettuce_image_url": "https://www.gardeningknowhow.com/wp-content/uploads/2021/05/lettuce-with-brown-edges.jpg",
    "sensors": {
      "ec": 790.5,
      "ph": 6.4,
      "temp_c": 25.1
    },
    "predictions": {
      "n_ppm": 139.4,
      "p_ppm": 46.5,
      "k_ppm": 185.8
    },
    "status": {
      "n_status": "low",
      "p_status": "ok",
      "k_status": "ok",
      "overall_status": "warning"
    },
    "recommendation": "Nitrogen is low. Consider adding 10ml of 'Grow' solution."
  };

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LeafCloud Dashboard'),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(),
            const SizedBox(height: 24),
            _buildRecommendationCard(),
            const SizedBox(height: 24),
            _buildStatusGrid(),
            const SizedBox(height: 24),
            _buildSensorReadings(),
            const SizedBox(height: 24),
            _buildNutrientPredictions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plant: ${data['plant_id']}',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated: ${data['timestamp']}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: Image.network(
              data['lettuce_image_url'],
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, size: 200),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendation',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              data['recommendation'],
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusGrid() {
    final status = data['status'] as Map<String, dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nutrient Status', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            Text('Nitrogen (N): ${status['n_status']}'),
            Text('Phosphorus (P): ${status['p_status']}'),
            Text('Potassium (K): ${status['k_status']}'),
          ],
        ),
      ],
    );
  }

  Widget _buildSensorReadings() {
    final sensors = data['sensors'] as Map<String, dynamic>;
    return _buildInfoCard(
      title: 'Live Sensor Data',
      icon: Icons.sensors,
      children: [
        _buildInfoRow('EC', '${sensors['ec']} µS/cm'),
        _buildInfoRow('pH', '${sensors['ph']}'),
        _buildInfoRow('Temperature', '${sensors['temp_c']} °C'),
      ],
    );
  }

  Widget _buildNutrientPredictions() {
    final predictions = data['predictions'] as Map<String, dynamic>;
    return _buildInfoCard(
      title: 'NPK Predictions (ppm)',
      icon: Icons.science,
      children: [
        _buildInfoRow('Nitrogen (N)', '${predictions['n_ppm']}'),
        _buildInfoRow('Phosphorus (P)', '${predictions['p_ppm']}'),
        _buildInfoRow('Potassium (K)', '${predictions['k_ppm']}'),
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