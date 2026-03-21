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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Data Gathering', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
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
            color: Colors.green[700],
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildWarningBanner(),
                  _buildHeader(data),
                  const SizedBox(height: 24),
                  _buildApiStatus(context),
                  const SizedBox(height: 24),
                  _buildBucketControl(context),
                  const SizedBox(height: 24),
                  _buildPHControl(context),
                  const SizedBox(height: 24),
                  _buildCalibrationControl(context),
                  const SizedBox(height: 24),
                  _buildSystemControl(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalibrationControl(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.compass_calibration, color: Colors.purple, size: 22),
              SizedBox(width: 8),
              Text(
                'Sensor Calibration',
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
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 1,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 5,
                children: [
                  _buildCalibrationButton(context, 'EC 1413 Calibrate', () => _handleProtocolCalibration(context, 'ec')),
                  _buildCalibrationButton(context, 'PH 4.01 Calibrate', () => _handleProtocolCalibration(context, 'ph_401')),
                  _buildCalibrationButton(context, 'PH 8.86 Calibrate', () => _handleProtocolCalibration(context, 'ph_686')),
                  _buildCalibrationButton(context, 'STOP Calibration', () => _handleProtocolCalibration(context, 'stop'), isStop: true),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationButton(BuildContext context, String label, VoidCallback onPressed, {bool isStop = false}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isStop ? Colors.red[50] : Colors.purple[50],
        foregroundColor: isStop ? Colors.red[700] : Colors.purple[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isStop ? Colors.red[100]! : Colors.purple[100]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
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

  Widget _buildSystemControl(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.settings_remote, color: Colors.orange, size: 22),
              SizedBox(width: 8),
              Text(
                'System Control',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Consumer<BucketControlNotifier>(
          builder: (context, notifier, child) {
            final bool isRestarting = notifier.isLoading && notifier.sendingLabel == null;
            
            return Container(
              width: double.infinity,
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
              child: Column(
                children: [
                  Text(
                    'Perform administrative actions on the remote IoT device.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: notifier.isLoading ? null : () => _showRestartConfirmationDialog(context),
                      icon: isRestarting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.restart_alt),
                      label: Text(
                        isRestarting ? 'Restarting...' : 'Restart System',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRestarting ? Colors.grey : Colors.orange[800],
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Note: This will temporarily interrupt the video feed (~20s).',
                    style: TextStyle(fontSize: 11, color: Colors.grey[500], fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
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

  Widget _buildWarningBanner() {
    return Consumer<BucketControlNotifier>(
      builder: (context, notifier, child) {
        if (!notifier.phUpdateRequested) return const SizedBox.shrink();
        
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red[700],
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withAlpha(40),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'pH Correction Active: Raspberry Pi is in high-power mode updating historical records.',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(SensorData data) {
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
            Consumer<SensorDataNotifier>(
              builder: (context, notifier, child) {
                if (notifier.isLoading) {
                  return const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                return const SizedBox.shrink();
              },
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
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: VideoFeedWidget(url: _getVideoUrl(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiStatus(BuildContext context) {
    return Consumer<BucketControlNotifier>(
      builder: (context, notifier, child) {
        final isError = notifier.errorMessage != null;
        final isLoading = notifier.isLoading;

        String statusText = 'Active Bucket: ${notifier.activeBucketStatus}';
        if (isLoading && notifier.sendingLabel != null) {
          statusText = 'Sending: ${notifier.sendingLabel}...';
        } else if (isError) {
          statusText = notifier.errorMessage!;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isError ? Colors.red[50] : (isLoading ? Colors.blue[50] : Colors.green[50]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isError ? Colors.red[200]! : (isLoading ? Colors.blue[200]! : Colors.green[200]!),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isError ? Icons.error_outline : (isLoading ? Icons.send : Icons.check_circle_outline),
                color: isError ? Colors.red : (isLoading ? Colors.blue : Colors.green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isError ? 'API Error' : (isLoading ? 'Request Sent' : 'System Control Status'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isError ? Colors.red[900] : (isLoading ? Colors.blue[900] : Colors.green[900]),
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 13,
                        color: isError ? Colors.red[700] : (isLoading ? Colors.blue[700] : Colors.green[700]),
                      ),
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
          child: Column(
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 3,
                children: [
                  _buildControlButton(context, 'NPK'),
                  _buildControlButton(context, 'Micro'),
                  _buildControlButton(context, 'Mix'),
                  _buildControlButton(context, 'Water'),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: _buildControlButton(context, 'Stop', isStop: true)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton(BuildContext context, String label, {bool isStop = false}) {
    final notifier = context.read<BucketControlNotifier>();
    return ElevatedButton(
      onPressed: () {
        notifier.setActiveBucket(isStop ? 'STOP' : label);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isStop ? Colors.red[50] : Colors.green[50],
        foregroundColor: isStop ? Colors.red[700] : Colors.green[700],
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isStop ? Colors.red[100]! : Colors.green[100]!),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildPHControl(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.history_edu, color: Colors.blue, size: 22),
              SizedBox(width: 8),
              Text(
                'Update PH',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Consumer<BucketControlNotifier>(
          builder: (context, notifier, child) {
            final isActive = notifier.phUpdateRequested;
            return Container(
              width: double.infinity,
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
              child: Column(
                children: [
                  Text(
                    isActive 
                      ? 'Correction session active. Pi is updating historical records.'
                      : 'Probe is in hybrid mode. Start correction to backfill historical data.',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: notifier.isLoading ? null : () => _togglePHSession(context),
                      icon: notifier.isLoading 
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                        : Icon(isActive ? Icons.pause_circle_filled : Icons.history_edu),
                      label: Text(
                        isActive ? 'Stop Updating' : 'Update pH',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isActive ? Colors.red[50] : Colors.blue[50],
                        foregroundColor: isActive ? Colors.red[700] : Colors.blue[700],
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isActive ? Colors.red[100]! : Colors.blue[100]!),
                        ),
                      ),
                    ),
                  ),
                ],
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
}
