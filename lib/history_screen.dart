import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_leafcloud_app/notifiers/history_notifier.dart';
import 'package:flutter_leafcloud_app/models/history_entry.dart';

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
      context.read<HistoryNotifier>().fetchHistory(
        _experimentIdController.text.isNotEmpty ? _experimentIdController.text : null
      );
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

                if (notifier.historyData.isEmpty) {
                  return const Center(
                    child: Text(
                      'No history data found.\nTry a different Experiment ID or wait for data ingestion.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final listData = notifier.currentBucketData.reversed.toList();

                return Column(
                  children: [
                    if (notifier.availableBuckets.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Select Bucket:', style: TextStyle(fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                              value: notifier.selectedBucket,
                              items: notifier.availableBuckets.map((String bucket) {
                                return DropdownMenuItem<String>(
                                  value: bucket,
                                  child: Text(bucket),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  notifier.selectBucket(newValue);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _buildChart(notifier.currentBucketData),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: listData.length,
                        itemBuilder: (context, index) {
                          final entry = listData[index];
                          
                          final String formattedDate = DateFormat.yMMMd().add_jm().format(entry.timestamp);

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
                                  _buildDataRow('EC', '${entry.ec?.toStringAsFixed(2) ?? 'N/A'} mS/cm'),
                                  _buildDataRow('pH', '${entry.ph?.toStringAsFixed(2) ?? 'N/A'}'),
                                  _buildDataRow('Water Temp', '${entry.waterTemp?.toStringAsFixed(1) ?? entry.temp?.toStringAsFixed(1) ?? 'N/A'} °C'),
                                  if (entry.imageUrl != null) ...[
                                    const Divider(),
                                    _buildDataRow('Image', 'Available'),
                                  ],
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

  Widget _buildChart(List<HistoryEntry> data) {
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
          _buildLine(Colors.blue, (e) => e.ec, data),
          _buildLine(Colors.red, (e) => e.ph, data),
          _buildLine(Colors.orange, (e) => e.displayTemp, data),
        ],
      ),
    );
  }

  LineChartBarData _buildLine(Color color, double? Function(HistoryEntry) selector, List<HistoryEntry> data) {
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      final val = selector(data[i]);
      if (val != null) {
        spots.add(FlSpot(i.toDouble(), val));
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
