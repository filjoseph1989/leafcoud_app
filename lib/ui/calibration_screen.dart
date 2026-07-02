import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:leaf_cloud/providers/calibration_provider.dart';
import 'package:leaf_cloud/models/calibration_model.dart';
import 'package:leaf_cloud/ui/widgets/app_footer.dart';
import 'package:leaf_cloud/providers/auth_provider.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalibrationProvider>().fetchCalibrations();
    });
    _startPolling();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        context.read<CalibrationProvider>().fetchCalibrations(showLoading: false);
      }
    });
  }

  String _formatSensorName(String name) {
    if (name.isEmpty) return 'Unknown Sensor';
    return name
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) {
          if (w.toLowerCase() == 'ph') return 'pH';
          if (w.toLowerCase() == 'ec') return 'EC';
          return w[0].toUpperCase() + w.substring(1);
        })
        .join(' ');
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    final year = local.year;
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final second = local.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = Provider.of<AuthProvider>(context).isAdmin;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Calibration'),
        backgroundColor: const Color(0xFF4E7A43),
        foregroundColor: Colors.white,
        actions: [
          Consumer<CalibrationProvider>(
            builder: (context, provider, child) {
              return IconButton(
                icon: provider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                onPressed: provider.isLoading
                    ? null
                    : () => provider.fetchCalibrations(),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: const AppFooter(),
      body: Consumer<CalibrationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.calibrations.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4E7A43),
              ),
            );
          }

          if (provider.errorMessage != null && provider.calibrations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load calibrations',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => provider.fetchCalibrations(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E7A43),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.calibrations.isEmpty) {
            return const Center(
              child: Text('No calibration data found.'),
            );
          }

          final allCalibrating = provider.calibrations.isNotEmpty &&
              provider.calibrations.every((c) => c.isCalibrating);

          return RefreshIndicator(
            onRefresh: () => provider.fetchCalibrations(),
            color: const Color(0xFF4E7A43),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.calibrations.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _buildMasterToggle(context, provider, allCalibrating, isAdmin);
                return _buildCalibrationCard(context, provider, provider.calibrations[index - 1], isAdmin);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildMasterToggle(BuildContext context, CalibrationProvider provider, bool allCalibrating, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: allCalibrating ? Colors.orange.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: allCalibrating ? Colors.orange : Colors.grey.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.tune,
            color: allCalibrating ? Colors.orange : Colors.grey[500],
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Calibrating Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  allCalibrating ? 'All sensors are calibrating' : 'All sensors are idle',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Switch(
            value: allCalibrating,
            activeThumbColor: Colors.orange,
            activeTrackColor: Colors.orange.withValues(alpha: 0.4),
            inactiveThumbColor: Colors.grey[400],
            inactiveTrackColor: Colors.grey[200],
            onChanged: isAdmin ? (value) async {
              for (final c in provider.calibrations) {
                await provider.toggleCalibration(c.id, value);
              }
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCalibrationCard(
    BuildContext context,
    CalibrationProvider provider,
    SensorCalibration calibration,
    bool isAdmin,
  ) {
    final isCalibrating = calibration.isCalibrating;
    final isPh = calibration.sensorName.toLowerCase().contains('ph');
    
    final statusColor = isCalibrating ? Colors.orange : const Color(0xFF4E7A43);
    final iconData = isPh ? Icons.science : Icons.bolt;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCalibrating ? Colors.orange.withValues(alpha: 0.5) : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left icon container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isPh ? Colors.blue : Colors.purple).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: isPh ? Colors.blue : Colors.purple,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            
            // Middle text description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatSensorName(calibration.sensorName),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCalibrating ? 'CALIBRATING' : 'IDLE',
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last Updated: ${_formatDateTime(calibration.updatedAt)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
            
            // Switch control
            Switch(
              value: isCalibrating,
              activeThumbColor: Colors.orange,
              activeTrackColor: Colors.orange.withValues(alpha: 0.4),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[200],
              onChanged: isAdmin ? (value) async {
                final success = await provider.toggleCalibration(calibration.id, value);
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update calibration: ${provider.errorMessage ?? "Unknown error"}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } : null,
            ),
          ],
        ),
      ),
    );
  }
}
