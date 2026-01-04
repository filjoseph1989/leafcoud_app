import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> historyData = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      // Endpoint per docs/leafcloud_experiment_setup_10.md
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/app/history/?limit=30'));
      
      if (response.statusCode == 200) {
        final List<dynamic> rawData = json.decode(response.body);
        setState(() {
          historyData = rawData.map((item) => item as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'Failed to load history: ${response.statusCode}';
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
        title: const Text('History'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : historyData.isEmpty
                  ? const Center(child: Text('No history available'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      itemCount: historyData.length,
                      itemBuilder: (context, index) {
                        final entry = historyData[index];
                        // Parsing values from API keys (n_ppm, p_ppm, k_ppm)
                        // Note: Dashboard uses 'Nitrogen', but history API uses 'n_ppm' per docs
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
                                _buildDataRow('Nitrogen', '${entry['n_ppm']?.toStringAsFixed(1) ?? 'N/A'} ppm'),
                                _buildDataRow('Phosphorus', '${entry['p_ppm']?.toStringAsFixed(1) ?? 'N/A'} ppm'),
                                _buildDataRow('Potassium', '${entry['k_ppm']?.toStringAsFixed(1) ?? 'N/A'} ppm'),
                                const Divider(),
                                _buildDataRow('EC', '${entry['ec']?.toStringAsFixed(2) ?? 'N/A'} mS/cm'),
                                _buildDataRow('pH', '${entry['ph']?.toStringAsFixed(2) ?? 'N/A'}'),
                                _buildDataRow('Temp', '${entry['temp']?.toStringAsFixed(1) ?? 'N/A'} °C'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }
}
