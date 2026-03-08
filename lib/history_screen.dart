import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_leafcloud_app/notifiers/history_notifier.dart';

class HistoryScreen extends StatefulWidget {
  final String? experimentId;
  const HistoryScreen({super.key, this.experimentId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _experimentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _experimentIdController.text = widget.experimentId ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_experimentIdController.text.isNotEmpty) {
        context.read<HistoryNotifier>().fetchHistory(_experimentIdController.text);
      }
    });
  }

  @override
  void dispose() {
    _experimentIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiment History'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _experimentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Experiment ID',
                      border: OutlineInputBorder(),
                      hintText: 'e.g., EXP-NPK-AUTO',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    final id = _experimentIdController.text.trim();
                    if (id.isNotEmpty) {
                      context.read<HistoryNotifier>().fetchHistory(id);
                    }
                  },
                  icon: const Icon(Icons.search),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<HistoryNotifier>(
              builder: (context, notifier, child) {
                if (notifier.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (notifier.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(notifier.errorMessage!, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  );
                }

                if (notifier.bucketData.isEmpty) {
                  return const Center(child: Text('Enter an Experiment ID to view history'));
                }

                final listData = notifier.bucketData.reversed.toList();

                return Column(
                  children: [
                    SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildChart(notifier.bucketData),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: listData.length,
                        itemBuilder: (context, index) {
                          final entry = listData[index] as Map<String, dynamic>;
                          
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<dynamic> data) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          _buildLine(Colors.blue, 'n_ppm', data),
          _buildLine(Colors.red, 'p_ppm', data),
          _buildLine(Colors.orange, 'k_ppm', data),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(Color color, String key, List<dynamic> data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final val = (data[i] as Map<String, dynamic>)[key];
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
