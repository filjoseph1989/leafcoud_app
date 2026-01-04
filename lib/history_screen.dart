import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

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
    // For List: Newest first (Reverse of API response)
    final listData = historyData.reversed.toList();

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
                  : Column(
                      children: [
                        SizedBox(
                          height: 250,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: _buildChart(),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: listData.length,
                            itemBuilder: (context, index) {
                              final entry = listData[index];
                              
                              String formattedDate = 'Unknown';
                              if (entry['timestamp'] != null) {
                                try {
                                  final DateTime parsedDate = DateTime.parse(entry['timestamp']);
                                  formattedDate = DateFormat.yMMMd().add_jm().format(parsedDate);
                                } catch (e) {
                                  formattedDate = entry['timestamp'].toString();
                                }
                              }

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Timestamp: $formattedDate',
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
                        ),
                      ],
                    ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false), // Hide dates for cleaner look
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          _buildLine(Colors.blue, 'n_ppm'), // Nitrogen
          _buildLine(Colors.red, 'p_ppm'),  // Phosphorus
          _buildLine(Colors.orange, 'k_ppm'), // Potassium
        ],
      ),
    );
  }

  LineChartBarData _buildLine(Color color, String key) {
    List<FlSpot> spots = [];
    for (int i = 0; i < historyData.length; i++) {
      final val = historyData[i][key];
      if (val != null) {
        spots.add(FlSpot(i.toDouble(), (val as num).toDouble()));
      }
    }
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(show: false),
      barWidth: 3,
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