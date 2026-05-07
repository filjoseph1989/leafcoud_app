import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/landing_screen.dart';
import 'package:flutter_leafcloud_app/history_screen.dart';
import 'package:flutter_leafcloud_app/alerts_screen.dart';
import 'package:flutter_leafcloud_app/image_gallery_screen.dart';
import 'package:flutter_leafcloud_app/data_gathering_screen.dart';
import 'package:flutter_leafcloud_app/trash_screen.dart';
import 'package:flutter_leafcloud_app/image_cropper_screen.dart';
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
            icon: Icon(Icons.history_rounded, color: theme.colorScheme.primary),
            tooltip: 'History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
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
            _buildDrawerItem(context, Icons.crop_rounded, 'Image Cropper', const ImageCropperScreen()),
            _buildDrawerItem(context, Icons.photo_library_outlined, 'Image Gallery', const ImageGalleryScreen()),
            _buildDrawerItem(context, Icons.delete_outline_rounded, 'Trash', const TrashScreen()),
            const Divider(indent: 20, endIndent: 20),
            _buildDrawerItem(context, Icons.logout_rounded, 'Logout', null, isDestructive: true),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
              child: Column(
                children: [
                  Divider(color: Colors.grey[200]),
                  const SizedBox(height: 12),
                  Text(
                    'LeafCloud v1.0.0',
                    style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2026 Toraque, Cordero, Gregorio. All rights reserved.',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),
                ],
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
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: () => notifier.fetchSensorData(),
                      label: const Text('Retry Connection'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LandingScreen()),
                        (route) => false,
                      );
                    },
                    child: const Text('Back to Landing Page'),
                  ),
                ],
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
            _buildNutrientPredictions(data),
            const SizedBox(height: 32),
            _buildRecommendationCard(data),
            const SizedBox(height: 24),
            _buildStatusCard(data),
            const SizedBox(height: 32),
            _buildSensorReadings(data),
            const SizedBox(height: 40),
            _buildFooter(),
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
    final cnnLabel = data.cnnClassification;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                  if (cnnLabel != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 11, color: statusColor.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          'AI: $cnnLabel',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: statusColor.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: Colors.grey[200]),
        const SizedBox(height: 12),
        Text(
          'LeafCloud v1.0.0',
          style: TextStyle(fontSize: 11, color: Colors.grey[400], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          '© 2026 Toraque, Cordero, Gregorio. All rights reserved.',
          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
      ],
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

    final double n = double.tryParse('${levels['n'] ?? levels['n_ppm'] ?? levels['Nitrogen'] ?? 0}') ?? 0;
    final double p = double.tryParse('${levels['p'] ?? levels['p_ppm'] ?? levels['Phosphorus'] ?? 0}') ?? 0;
    final double k = double.tryParse('${levels['k'] ?? levels['k_ppm'] ?? levels['Potassium'] ?? 0}') ?? 0;
    final double total = n + p + k;

    return _buildNpkGaugeSection(n: n, p: p, k: k, total: total);
  }

  Widget _buildNpkGaugeSection({required double n, required double p, required double k, required double total}) {
    final theme = Theme.of(context);
    // Optimal total NPK range ~500–900 ppm; max gauge at 1200 ppm
    const double maxPpm = 1200;
    final double fraction = (total / maxPpm).clamp(0.0, 1.0);

    final Color gaugeColor;
    final String strengthLabel;
    if (fraction < 0.25) {
      gaugeColor = Colors.red[400]!;
      strengthLabel = 'Very Low';
    } else if (fraction < 0.45) {
      gaugeColor = Colors.orange[400]!;
      strengthLabel = 'Low';
    } else if (fraction < 0.70) {
      gaugeColor = theme.colorScheme.primary;
      strengthLabel = 'Optimal';
    } else if (fraction < 0.90) {
      gaugeColor = Colors.amber[600]!;
      strengthLabel = 'High';
    } else {
      gaugeColor = Colors.red[400]!;
      strengthLabel = 'Excess';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Nutrient Analysis',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Total NPK Strength',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 160,
                width: 160,
                child: CustomPaint(
                  painter: _NpkGaugePainter(
                    fraction: fraction,
                    gaugeColor: gaugeColor,
                    trackColor: Colors.grey[200]!,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total.toStringAsFixed(0),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: gaugeColor,
                          ),
                        ),
                        Text(
                          'ppm',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: gaugeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            strengthLabel,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: gaugeColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNpkBreakdown('N', n, Colors.green[700]!),
                  _buildNpkDivider(),
                  _buildNpkBreakdown('P', p, Colors.blue[600]!),
                  _buildNpkDivider(),
                  _buildNpkBreakdown('K', k, Colors.orange[700]!),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNpkBreakdown(String label, double value, Color color) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toStringAsFixed(0),
          style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          'ppm',
          style: theme.textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildNpkDivider() {
    return Container(width: 1, height: 40, color: Colors.grey[200]);
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
          SizedBox(
            width: double.infinity,
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: theme.colorScheme.primary.withOpacity(0.5)),
              const SizedBox(height: 10),
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  unit,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          ),
        ],
      ),
    );
  }
}

class _NpkGaugePainter extends CustomPainter {
  final double fraction;
  final Color gaugeColor;
  final Color trackColor;

  _NpkGaugePainter({required this.fraction, required this.gaugeColor, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 14;
    const double startAngle = 2.35; // ~135 degrees (bottom-left)
    const double sweepTotal = 4.71; // ~270 degrees

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final gaugePaint = Paint()
      ..color = gaugeColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, startAngle, sweepTotal, false, trackPaint);
    if (fraction > 0) {
      canvas.drawArc(rect, startAngle, sweepTotal * fraction, false, gaugePaint);
    }
  }

  @override
  bool shouldRepaint(_NpkGaugePainter old) =>
      old.fraction != fraction || old.gaugeColor != gaugeColor;
}
