import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/history_model.dart';
import 'package:leaf_cloud/providers/config_provider.dart';
import 'package:leaf_cloud/providers/iot_provider.dart';
import 'package:leaf_cloud/ui/widgets/app_footer.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  int _selectedDays = 7;
  late TabController _tabController;

  static const _dayOptions = [7, 30, 90];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final config = context.read<ConfigProvider>().activeConfig;
    if (config != null) {
      await context.read<IotProvider>().fetchHistory(config.id!, days: _selectedDays);
    }
  }

  void _selectDays(int days) {
    if (_selectedDays == days) return;
    setState(() => _selectedDays = days);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
        centerTitle: true,
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.photo_library), text: 'Photos'),
            Tab(icon: Icon(Icons.show_chart), text: 'Trends'),
          ],
        ),
      ),
      bottomNavigationBar: const AppFooter(),
      body: Consumer2<ConfigProvider, IotProvider>(
        builder: (context, configProvider, iotProvider, _) {
          if (configProvider.activeConfig == null) {
            return const Center(child: Text('No active reservoir. Please configure one first.'));
          }

          return Column(
            children: [
              _buildDaySelector(),
              Expanded(
                child: _buildBody(iotProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _dayOptions.map((d) {
          final selected = _selectedDays == d;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text('$d days'),
              selected: selected,
              onSelected: (_) => _selectDays(d),
              selectedColor: const Color(0xFF4E7A43),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(IotProvider iotProvider) {
    if (iotProvider.isHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (iotProvider.historyError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(iotProvider.historyError!, textAlign: TextAlign.center),
        ),
      );
    }
    final data = iotProvider.historyData;
    if (data == null || data.readings.isEmpty) {
      return const Center(child: Text('No readings found for this period.'));
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _PhotosTab(readings: data.readings),
        _TrendsTab(readings: data.readings),
      ],
    );
  }
}

// ─── Photos Tab ───────────────────────────────────────────────────────────────

class _PhotosTab extends StatelessWidget {
  final List<HistoryReading> readings;
  const _PhotosTab({required this.readings});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: readings.length,
      itemBuilder: (context, index) => _ReadingCard(reading: readings[index]),
    );
  }
}

class _ReadingCard extends StatelessWidget {
  final HistoryReading reading;
  const _ReadingCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    final ts = reading.timestamp;
    final dateStr = '${ts.year}-${_pad(ts.month)}-${_pad(ts.day)}';
    final timeStr = '${_pad(ts.hour)}:${_pad(ts.minute)}';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          GestureDetector(
            onTap: () => _openFullImage(context),
            child: SizedBox(
              height: 180,
              width: double.infinity,
              child: Image.network(
                reading.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context2, e, stack) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.broken_image, size: 40, color: Colors.grey)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Timestamp
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('$dateStr  $timeStr', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const Spacer(),
                    if (!reading.hasAiData)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber[100],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber),
                        ),
                        child: const Text('AI Pending', style: TextStyle(fontSize: 11, color: Colors.orange)),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // Sensor chips
                Row(
                  children: [
                    _sensorChip('pH', reading.ph.toStringAsFixed(1), Colors.blue),
                    const SizedBox(width: 8),
                    _sensorChip('EC', reading.ec.toStringAsFixed(2), Colors.orange),
                    const SizedBox(width: 8),
                    _sensorChip('${reading.waterTemp.toStringAsFixed(1)}°C', 'Temp', Colors.red),
                  ],
                ),
                // Scale bars (only if AI data available)
                if (reading.hasAiData) ...[
                  const SizedBox(height: 10),
                  _scaleBar('Macro', reading.macroScale ?? 0),
                  const SizedBox(height: 4),
                  _scaleBar('Micro', reading.microScale ?? 0),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sensorChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: value, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
            TextSpan(text: ' $label', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _scaleBar(String label, double value) {
    final pct = (value * 100).clamp(0, 100).toInt();
    final color = pct >= 70 ? const Color(0xFF4E7A43) : Colors.orange;
    return Row(
      children: [
        SizedBox(width: 44, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text('$pct%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  void _openFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: Center(
            child: InteractiveViewer(
              child: Image.network(reading.imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  String _pad(int n) => n.toString().padLeft(2, '0');
}

// ─── Trends Tab ───────────────────────────────────────────────────────────────

class _TrendsTab extends StatelessWidget {
  final List<HistoryReading> readings;
  const _TrendsTab({required this.readings});

  // readings are newest-first; reverse for chart x-axis (oldest→newest)
  List<HistoryReading> get _chronological => readings.reversed.toList();

  @override
  Widget build(BuildContext context) {
    final data = _chronological;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ChartCard(title: 'pH', color: Colors.blue, spots: _spots(data, (r) => r.ph)),
        const SizedBox(height: 16),
        _ChartCard(title: 'EC (mS/cm)', color: Colors.orange, spots: _spots(data, (r) => r.ec)),
        const SizedBox(height: 16),
        _ChartCard(title: 'Water Temp (°C)', color: Colors.red, spots: _spots(data, (r) => r.waterTemp)),
        const SizedBox(height: 16),
        _ScaleChartCard(data: data),
      ],
    );
  }

  List<FlSpot> _spots(List<HistoryReading> data, double Function(HistoryReading) value) {
    return List.generate(data.length, (i) => FlSpot(i.toDouble(), value(data[i])));
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<FlSpot> spots;

  const _ChartCard({required this.title, required this.color, required this.spots});

  @override
  Widget build(BuildContext context) {
    if (spots.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text(v.toStringAsFixed(1), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    dotData: FlDotData(show: spots.length <= 10),
                    belowBarData: BarAreaData(
                      show: true,
                      color: color.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScaleChartCard extends StatelessWidget {
  final List<HistoryReading> data;
  const _ScaleChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final macroSpots = <FlSpot>[];
    final microSpots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final r = data[i];
      if (r.macroScale != null) macroSpots.add(FlSpot(i.toDouble(), r.macroScale!));
      if (r.microScale != null) microSpots.add(FlSpot(i.toDouble(), r.microScale!));
    }

    if (macroSpots.isEmpty && microSpots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: const Text('No AI scale data available yet.', style: TextStyle(color: Colors.grey)),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Nutrient Scale (AI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            children: [
              _legend(Colors.green[700]!, 'Macro'),
              const SizedBox(width: 16),
              _legend(Colors.purple, 'Micro'),
              const SizedBox(width: 16),
              Container(
                width: 32,
                height: 1.5,
                color: Colors.red.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              const Text('70% threshold', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 1,
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(color: Colors.grey.withValues(alpha: 0.2), strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 36,
                      getTitlesWidget: (v, _) => Text('${(v * 100).toInt()}%', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ),
                  bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(y: 0.7, color: Colors.red.withValues(alpha: 0.5), strokeWidth: 1.5, dashArray: [4, 4]),
                  ],
                ),
                lineBarsData: [
                  if (macroSpots.isNotEmpty)
                    LineChartBarData(
                      spots: macroSpots,
                      isCurved: true,
                      color: Colors.green[700],
                      barWidth: 2.5,
                      dotData: FlDotData(show: macroSpots.length <= 10),
                      belowBarData: BarAreaData(show: true, color: Colors.green.withValues(alpha: 0.06)),
                    ),
                  if (microSpots.isNotEmpty)
                    LineChartBarData(
                      spots: microSpots,
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 2.5,
                      dotData: FlDotData(show: microSpots.length <= 10),
                      belowBarData: BarAreaData(show: true, color: Colors.purple.withValues(alpha: 0.06)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(
      children: [
        Container(width: 16, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}
