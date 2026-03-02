import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_leafcloud_app/history_screen.dart';
import 'package:flutter_leafcloud_app/alerts_screen.dart';
import 'package:flutter_leafcloud_app/widgets/video_feed_widget.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SensorDataNotifier>().startPolling(interval: const Duration(seconds: 10));
      context.read<BucketControlNotifier>().startPolling(interval: const Duration(seconds: 2));
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('LeafCloud Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
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
      body: Consumer<SensorDataNotifier>(
        builder: (context, notifier, child) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: _buildBody(notifier),
          );
        },
      ),
    );
  }

  Widget _buildBody(SensorDataNotifier notifier) {
    if (notifier.isLoading && notifier.data == null) {
      return const Center(key: ValueKey('loading'), child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null && notifier.data == null) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Connection Failed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                notifier.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                onPressed: () => notifier.fetchSensorData(),
                label: const Text('Retry Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data = notifier.data;
    if (data == null) {
      return const Center(key: ValueKey('no-data'), child: Text('No data available'));
    }

    return RefreshIndicator(
      key: const ValueKey('content'),
      onRefresh: () => notifier.fetchSensorData(),
      color: Colors.green[700],
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildHeader(data),
            const SizedBox(height: 24),
            _buildRecommendationCard(data),
            const SizedBox(height: 24),
            _buildStatusCard(data),
            const SizedBox(height: 24),
            _buildBucketControl(context),
            const SizedBox(height: 24),
            _buildSensorReadings(data),
            const SizedBox(height: 24),
            _buildNutrientPredictions(data),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(SensorData data) {
    const String videoUrl = 'http://192.168.1.7:8000/video_feed';
    String formattedDate = DateFormat.yMMMd().add_jm().format(data.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Live Monitor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (context.watch<SensorDataNotifier>().isLoading)
              const SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Last sync: $formattedDate',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: VideoFeedWidget(url: videoUrl),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationCard(SensorData data) {
    final recommendation = data.recommendation ?? 'Everything looks great!';
    final statusData = data.status;
    Color themeColor = Colors.orange;

    if (statusData is String && statusData == "Optimal") {
      themeColor = Colors.green;
    } else if (statusData is Map && statusData['overall_status'] == "Optimal") {
      themeColor = Colors.green;
    }

    return Card(
      elevation: 0,
      color: themeColor.withAlpha(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: themeColor.withAlpha(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: themeColor),
                const SizedBox(width: 8),
                Text(
                  'Recommendation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: themeColor),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation,
              style: TextStyle(fontSize: 16, height: 1.4, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(SensorData data) {
    final statusData = data.status;
    String statusText = "Unknown";
    bool isOptimal = false;

    if (statusData is String) {
      statusText = statusData;
      isOptimal = statusText == "Optimal";
    } else if (statusData is Map) {
      statusText = statusData['overall_status']?.toString() ?? "Unknown";
      isOptimal = statusText == "Optimal";
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOptimal ? Colors.green[50] : Colors.orange[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOptimal ? Icons.check_circle_outline : Icons.warning_amber_rounded,
              color: isOptimal ? Colors.green[700] : Colors.orange[700],
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'System Health',
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 22, 
                    color: isOptimal ? Colors.green[800] : Colors.orange[800],
                    fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildBucketControl(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.tune, color: Colors.green, size: 22),
              SizedBox(width: 8),
              Text(
                'Bucket Control',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: [
              _buildControlButton(context, 'NPK'),
              _buildControlButton(context, 'Micro'),
              _buildControlButton(context, 'Mix'),
              _buildControlButton(context, 'Water'),
              _buildControlButton(context, 'Stop', isStop: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(BuildContext context, String label, {bool isStop = false}) {
    final notifier = context.read<BucketControlNotifier>();
    return ElevatedButton(
      onPressed: () => notifier.setActiveBucket(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isStop ? Colors.red[50] : Colors.green[50],
        foregroundColor: isStop ? Colors.red[700] : Colors.green[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isStop ? Colors.red[100]! : Colors.green[100]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSensorReadings(SensorData data) {
    final sensors = data.sensors;
    if (sensors == null) return const SizedBox.shrink();

    return _buildInfoSection(
      title: 'Environment Metrics',
      icon: Icons.thermostat_outlined,
      children: [
        _buildGridMetric('EC', '${sensors['ec'] ?? 'N/A'}', 'mS/cm', Icons.bolt),
        _buildGridMetric('pH', '${sensors['ph'] ?? 'N/A'}', '', Icons.opacity),
        _buildGridMetric('Temp', '${sensors['temp_c'] ?? sensors['temp'] ?? 'N/A'}', '°C', Icons.device_thermostat),
      ],
    );
  }

  Widget _buildNutrientPredictions(SensorData data) {
    final levels = data.predictions;
    if (levels == null) return const SizedBox.shrink();

    return _buildInfoSection(
      title: 'Nutrient Analysis',
      icon: Icons.science_outlined,
      children: [
        _buildGridMetric('Nitrogen', '${levels['n_ppm'] ?? levels['Nitrogen'] ?? 'N/A'}', 'ppm', Icons.nature),
        _buildGridMetric('Phosphorus', '${levels['p_ppm'] ?? levels['Phosphorus'] ?? 'N/A'}', 'ppm', Icons.grass),
        _buildGridMetric('Potassium', '${levels['k_ppm'] ?? levels['Potassium'] ?? 'N/A'}', 'ppm', Icons.local_florist),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required IconData icon, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.green[700], size: 22),
              const SizedBox(width: 8),
              Text(
                title, 
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: children,
        ),
      ],
    );
  }

  Widget _buildGridMetric(String label, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.green[600]),
          const SizedBox(height: 8),
          FittedBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (unit.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2.0),
                    child: Text(
                      unit,
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600], fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
