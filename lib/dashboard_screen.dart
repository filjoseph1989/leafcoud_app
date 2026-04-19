import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/landing_screen.dart';
import 'package:flutter_leafcloud_app/history_screen.dart';
import 'package:flutter_leafcloud_app/alerts_screen.dart';
import 'package:flutter_leafcloud_app/image_gallery_screen.dart';
import 'package:flutter_leafcloud_app/experiment_management_screen.dart';
import 'package:flutter_leafcloud_app/data_gathering_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('LeafCloud', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu_rounded, color: theme.colorScheme.primary),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: theme.colorScheme.primary),
            tooltip: 'Alerts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AlertsScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.eco_rounded, color: theme.colorScheme.primary, size: 40),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'LeafCloud',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildDrawerItem(context, Icons.analytics_outlined, 'Data Gathering', const DataGatheringScreen()),
            _buildDrawerItem(context, Icons.tune_rounded, 'Experiment Management', const ExperimentManagementScreen()),
            _buildDrawerItem(context, Icons.photo_library_outlined, 'Image Gallery', const ImageGalleryScreen()),
            _buildDrawerItem(context, Icons.history_rounded, 'History', HistoryScreen()),
            const Divider(indent: 20, endIndent: 20),
            _buildDrawerItem(context, Icons.logout_rounded, 'Logout', null, isDestructive: true),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'v1.0.0',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
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

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title, Widget? screen, {bool isDestructive = false}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red[400] : theme.colorScheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red[400] : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        if (isDestructive) {
          _handleLogout(context);
        } else if (screen != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        }
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SensorDataNotifier notifier) {
    final theme = Theme.of(context);
    if (notifier.isLoading && notifier.data == null) {
      return const Center(key: ValueKey('loading'), child: CircularProgressIndicator());
    }

    if (notifier.errorMessage != null && notifier.data == null) {
      return Center(
        key: const ValueKey('error'),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
              const SizedBox(height: 24),
              Text(
                'Connection Failed',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                notifier.errorMessage!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: () => notifier.fetchSensorData(),
                  label: const Text('Retry Connection'),
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
      color: theme.colorScheme.primary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildRecommendationCard(data),
            const SizedBox(height: 24),
            _buildStatusCard(data),
            const SizedBox(height: 32),
            _buildSensorReadings(data),
            const SizedBox(height: 32),
            _buildNutrientPredictions(data),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(SensorData data) {
    final theme = Theme.of(context);
    final recommendation = data.recommendation ?? 'Everything looks great!';
    final health = data.healthStatus;
    Color themeColor = Colors.orange;

    if (health == "Optimal") {
      themeColor = theme.colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: themeColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: themeColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lightbulb_rounded, color: themeColor, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Recommendation',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            recommendation,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(SensorData data) {
    final theme = Theme.of(context);
    final statusText = data.healthStatus;
    final isOptimal = statusText == "Optimal";
    final statusColor = isOptimal ? theme.colorScheme.primary : Colors.orange[700]!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isOptimal ? Icons.check_circle_rounded : Icons.warning_rounded,
                color: statusColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'System Health',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    statusText,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.primary.withOpacity(0.3), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorReadings(SensorData data) {
    return _buildInfoSection(
      title: 'Environment Metrics',
      icon: Icons.thermostat_rounded,
      aspectRatio: 0.70,
      children: [
        _buildGridMetric('EC', '${data.sensors?['ec'] ?? 'N/A'}', 'mS/cm', Icons.bolt_rounded),
        _buildGridMetric(
          'pH',
          '${data.sensors?['ph'] ?? 'N/A'}',
          '',
          Icons.opacity_rounded,
          showLiveBadge: data.phUpdateRequested,
        ),
        _buildGridMetric('Temp', '${data.sensors?['temp_c'] ?? data.sensors?['temp'] ?? 'N/A'}', '°C', Icons.thermostat_rounded),
      ],
    );
  }

  Widget _buildNutrientPredictions(SensorData data) {
    final levels = data.predictions;
    if (levels == null) return const SizedBox.shrink();

    return _buildInfoSection(
      title: 'Nutrient Analysis',
      icon: Icons.science_rounded,
      aspectRatio: 0.70,
      children: [
        _buildGridMetric('Nitrogen', '${levels['n'] ?? levels['n_ppm'] ?? levels['Nitrogen'] ?? 'N/A'}', 'ppm', Icons.nature_rounded),
        _buildGridMetric('Phosphorus', '${levels['p'] ?? levels['p_ppm'] ?? levels['Phosphorus'] ?? 'N/A'}', 'ppm', Icons.grass_rounded),
        _buildGridMetric('Potassium', '${levels['k'] ?? levels['k_ppm'] ?? levels['Potassium'] ?? 'N/A'}', 'ppm', Icons.local_florist_rounded),
      ],
    );
  }

  Widget _buildInfoSection({required String title, required IconData icon, required double aspectRatio, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: aspectRatio,
          children: children,
        ),
      ],
    );
  }

  Widget _buildGridMetric(String label, String value, String unit, IconData icon, {bool showLiveBadge = false}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: showLiveBadge ? Border.all(color: Colors.red[200]!, width: 2) : null,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showLiveBadge)
            Positioned(
              top: -12,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.primary.withOpacity(0.5)),
              const SizedBox(height: 8),
              FittedBox(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    if (unit.isNotEmpty) ...[
                      const SizedBox(width: 2),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: Text(
                          unit,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
