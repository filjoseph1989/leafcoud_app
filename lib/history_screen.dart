import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final List<Map<String, dynamic>> historyData = [
    {
      "timestamp": "2025-11-15T10:00:00Z",
      "n_ppm": 120.0,
      "p_ppm": 40.0,
      "k_ppm": 160.0,
      "ec": 750.0,
      "ph": 6.2,
      "temp_c": 24.5
    },
    {
      "timestamp": "2025-11-15T12:00:00Z",
      "n_ppm": 125.0,
      "p_ppm": 42.0,
      "k_ppm": 165.0,
      "ec": 760.0,
      "ph": 6.3,
      "temp_c": 24.8
    },
    {
      "timestamp": "2025-11-15T14:00:00Z",
      "n_ppm": 130.0,
      "p_ppm": 45.0,
      "k_ppm": 170.0,
      "ec": 770.0,
      "ph": 6.4,
      "temp_c": 25.0
    },
    {
      "timestamp": "2025-11-15T16:00:00Z",
      "n_ppm": 135.0,
      "p_ppm": 47.0,
      "k_ppm": 175.0,
      "ec": 780.0,
      "ph": 6.5,
      "temp_c": 25.2
    },
    {
      "timestamp": "2025-11-15T18:00:00Z",
      "n_ppm": 140.0,
      "p_ppm": 48.0,
      "k_ppm": 180.0,
      "ec": 790.0,
      "ph": 6.6,
      "temp_c": 25.5
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: historyData.length,
        itemBuilder: (context, index) {
          final entry = historyData[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timestamp: ${entry['timestamp']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text('N: ${entry['n_ppm']} ppm'),
                  Text('P: ${entry['p_ppm']} ppm'),
                  Text('K: ${entry['k_ppm']} ppm'),
                  Text('EC: ${entry['ec']} µS/cm'),
                  Text('pH: ${entry['ph']}'),
                  Text('Temp: ${entry['temp_c']} °C'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
