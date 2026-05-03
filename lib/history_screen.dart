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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Experiment History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _experimentIdController,
                    decoration: const InputDecoration(
                      hintText: 'Experiment ID (e.g., EXP-NPK)',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    onPressed: () {
                      final id = _experimentIdController.text.trim();
                      if (id.isNotEmpty) {
                        context.read<HistoryNotifier>().fetchHistory(id);
                      }
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    color: Colors.white,
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
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_off_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
                          const SizedBox(height: 24),
                          Text(
                            'Fetch Failed',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(notifier.errorMessage!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  );
                }

                if (notifier.historyData.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          Text(
                            'No history data found.\nTry a different Experiment ID.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final listData = notifier.currentBucketData.reversed.toList();

                return Column(
                  children: [
                    if (notifier.availableBuckets.length > 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Bucket', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                              DropdownButton<String>(
                                value: notifier.selectedBucket,
                                underline: const SizedBox(),
                                items: notifier.availableBuckets.map((String bucket) {
                                  return DropdownMenuItem<String>(
                                    value: bucket,
                                    child: Text(bucket, style: theme.textTheme.bodyMedium),
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
                      ),
                    SizedBox(
                      height: 250,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: _buildChart(theme, notifier.currentBucketData),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: listData.length,
                        itemBuilder: (context, index) {
                          final entry = listData[index];
                          final String formattedDate = DateFormat.yMMMd().add_jm().format(entry.timestamp);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      Icon(Icons.event_note_rounded, color: theme.colorScheme.primary.withOpacity(0.3), size: 20),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  const Divider(),
                                  const SizedBox(height: 12),
                                  _buildDataRow(theme, 'EC', '${entry.ec?.toStringAsFixed(2) ?? 'N/A'} mS/cm'),
                                  _buildDataRow(theme, 'pH', entry.ph?.toStringAsFixed(2) ?? 'N/A'),
                                  _buildDataRow(theme, 'Water Temp', '${entry.waterTemp?.toStringAsFixed(1) ?? entry.temp?.toStringAsFixed(1) ?? 'N/A'} °C'),
                                  if (entry.imageUrl != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(Icons.image_outlined, size: 14, color: theme.colorScheme.primary),
                                        const SizedBox(width: 4),
                                        Text('Image captured', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                                      ],
                                    ),
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

  Widget _buildChart(ThemeData theme, List<HistoryEntry> data) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: theme.colorScheme.onSurface.withOpacity(0.05),
            strokeWidth: 1,
          ),
        ),
        titlesData: const FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 30),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _buildLine(theme.colorScheme.primary, (e) => e.ec, data),
          _buildLine(theme.colorScheme.secondary, (e) => e.ph, data),
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
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.1),
      ),
      barWidth: 4,
    );
  }

  Widget _buildDataRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
