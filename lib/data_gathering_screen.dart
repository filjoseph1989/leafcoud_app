import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_leafcloud_app/widgets/video_feed_widget.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

class DataGatheringScreen extends StatefulWidget {
  const DataGatheringScreen({super.key});

  @override
  State<DataGatheringScreen> createState() => _DataGatheringScreenState();
}

class _DataGatheringScreenState extends State<DataGatheringScreen> {
  String _getVideoUrl(BuildContext context) {
    final apiService = Provider.of<ApiService>(context, listen: false);
    return '${apiService.baseUrl}/video_feed/';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Data Gathering', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<SensorDataNotifier>(
        builder: (context, notifier, child) {
          final data = notifier.data;
          if (notifier.isLoading && data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (data == null) {
            return const Center(child: Text('No data available'));
          }

          return RefreshIndicator(
            onRefresh: () => notifier.fetchSensorData(),
            color: theme.colorScheme.primary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildWarningBanner(theme),
                  _buildHeader(theme, data),
                  const SizedBox(height: 32),
                  _buildApiStatus(context, theme),
                  const SizedBox(height: 32),
                  _buildBucketControl(context, theme),
                  const SizedBox(height: 32),
                  _buildPHControl(context, theme),
                  const SizedBox(height: 32),
                  _buildCalibrationControl(context, theme),
                  const SizedBox(height: 32),
                  _buildSystemControl(context, theme),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalibrationControl(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sensor Calibration',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildCalibrationButton(theme, 'EC 1413', () => _handleProtocolCalibration(context, 'ec')),
                _buildCalibrationButton(theme, 'PH 4.01', () => _handleProtocolCalibration(context, 'ph_401')),
                _buildCalibrationButton(theme, 'PH 8.86', () => _handleProtocolCalibration(context, 'ph_686')),
                _buildCalibrationButton(theme, 'STOP', () => _handleProtocolCalibration(context, 'stop'), isStop: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationButton(ThemeData theme, String label, VoidCallback onPressed, {bool isStop = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isStop ? Colors.red[50] : theme.colorScheme.primary.withOpacity(0.05),
        foregroundColor: isStop ? Colors.red[700] : theme.colorScheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSystemControl(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Control',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<BucketControlNotifier>(
          builder: (context, notifier, child) {
            final bool isRestarting = notifier.isLoading && notifier.sendingLabel == null;
            
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Administrative actions for the remote IoT device.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: notifier.isLoading ? null : () => _showRestartConfirmationDialog(context),
                        icon: isRestarting
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.restart_alt_rounded),
                        label: Text(isRestarting ? 'Restarting...' : 'Restart System'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRestarting ? Colors.grey : Colors.orange[800],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Temporarily interrupts feed (~20s).',
                      style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWarningBanner(ThemeData theme) {
    return Consumer<BucketControlNotifier>(
      builder: (context, notifier, child) {
        if (!notifier.phUpdateRequested) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  'pH Correction Active: Raspberry Pi is in high-power mode.',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, SensorData data) {
    String formattedDate = DateFormat.yMMMd().add_jm().format(data.timestamp);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live Monitor',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          formattedDate,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.5)),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: VideoFeedWidget(url: _getVideoUrl(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiStatus(BuildContext context, ThemeData theme) {
    return Consumer<BucketControlNotifier>(
      builder: (context, notifier, child) {
        final isError = notifier.errorMessage != null;
        final isLoading = notifier.isLoading;
        final statusColor = isError ? Colors.red : (isLoading ? theme.colorScheme.secondary : theme.colorScheme.primary);

        String statusText = 'Active Bucket: ${notifier.activeBucketStatus}';
        if (isLoading && notifier.sendingLabel != null) {
          statusText = 'Sending: ${notifier.sendingLabel}...';
        } else if (isError) {
          statusText = notifier.errorMessage!;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isError ? Icons.error_outline_rounded : (isLoading ? Icons.send_rounded : Icons.check_circle_outline_rounded),
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isError ? 'API Error' : (isLoading ? 'Processing' : 'System Ready'),
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: statusColor),
                    ),
                    Text(
                      statusText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: statusColor.withOpacity(0.8)),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildBucketControl(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bucket Control',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: [
                    _buildControlButton(context, theme, 'NPK'),
                    _buildControlButton(context, theme, 'Micro'),
                    _buildControlButton(context, theme, 'Mix'),
                    _buildControlButton(context, theme, 'Water'),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(width: double.infinity, child: _buildControlButton(context, theme, 'Stop', isStop: true)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(BuildContext context, ThemeData theme, String label, {bool isStop = false}) {
    final notifier = context.read<BucketControlNotifier>();
    final color = isStop ? Colors.red : theme.colorScheme.primary;
    return ElevatedButton(
      onPressed: () {
        notifier.setActiveBucket(isStop ? 'STOP' : label);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.05),
        foregroundColor: color,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPHControl(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'pH Management',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<BucketControlNotifier>(
          builder: (context, notifier, child) {
            final isActive = notifier.phUpdateRequested;
            final color = isActive ? Colors.red : theme.colorScheme.secondary;
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      isActive 
                        ? 'Correction session active. Records are being updated.'
                        : 'Probe in hybrid mode. Start correction to backfill data.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: notifier.isLoading ? null : () => _togglePHSession(context),
                        icon: notifier.isLoading 
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(isActive ? Icons.pause_circle_filled_rounded : Icons.history_edu_rounded),
                        label: Text(isActive ? 'Stop Updating' : 'Start pH Correction'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: color.withOpacity(0.1),
                          foregroundColor: color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _togglePHSession(BuildContext context) async {
    final notifier = context.read<BucketControlNotifier>();
    final messenger = ScaffoldMessenger.of(context);
    await notifier.togglePHSession();
    if (notifier.errorMessage != null && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error: Could not toggle probe: ${notifier.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleProtocolCalibration(BuildContext context, String type) async {
    final messenger = ScaffoldMessenger.of(context);
    final apiService = context.read<BucketControlNotifier>().apiService;

    if (type == 'stop') {
      try {
        await apiService.requestCalibration('stop');
        messenger.showSnackBar(const SnackBar(content: Text('Calibration stopped successfully'), backgroundColor: Colors.green));
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text('Failed to stop calibration: $e'), backgroundColor: Colors.red));
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Calibration ($type)'),
        content: Text('Are you sure you want to request $type calibration? Ensure the probe is in the correct solution.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('CANCEL')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('CALIBRATE')),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await apiService.requestCalibration(type);
      messenger.showSnackBar(SnackBar(content: Text('$type calibration request sent successfully'), backgroundColor: Colors.green));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Calibration request failed: $e'), backgroundColor: Colors.red));
    }
  }

  void _showRestartConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm System Restart'),
          content: const Text(
            'Are you sure you want to restart the IoT system? \n\n'
            'This will reboot the camera and sensor script. '
            'The video feed and data ingestion will be interrupted for approximately 20-30 seconds.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleRestart();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.orange[800]),
              child: const Text('RESTART'),
            ),
          ],
        );
      },
    );
  }

  void _handleRestart() async {
    final notifier = context.read<BucketControlNotifier>();
    await notifier.restartIot();

    if (mounted) {
      if (notifier.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restart Failed: ${notifier.errorMessage}'),
            backgroundColor: Colors.red[700],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restart command sent successfully. System is rebooting...'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
