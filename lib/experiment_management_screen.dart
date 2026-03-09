import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';

class ExperimentManagementScreen extends StatefulWidget {
  const ExperimentManagementScreen({super.key});

  @override
  State<ExperimentManagementScreen> createState() => _ExperimentManagementScreenState();
}

class _ExperimentManagementScreenState extends State<ExperimentManagementScreen> {
  final _experimentIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final notifier = context.read<BucketControlNotifier>();
    _experimentIdController.text = notifier.activeExperimentId ?? '';
  }

  @override
  void dispose() {
    _experimentIdController.dispose();
    super.dispose();
  }

  void _saveExperimentId() async {
    final notifier = context.read<BucketControlNotifier>();
    final newId = _experimentIdController.text.trim();
    
    if (newId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Experiment ID cannot be empty')),
      );
      return;
    }

    await notifier.setExperimentId(newId);

    if (mounted) {
      if (notifier.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${notifier.errorMessage}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Active Experiment ID updated successfully')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiment Management'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Set Active Experiment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'This ID will link sensor data to a specific experiment on the server.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _experimentIdController,
              decoration: const InputDecoration(
                labelText: 'Experiment ID',
                border: OutlineInputBorder(),
                hintText: 'e.g., EXP-NPK-BATCH1',
              ),
            ),
            const SizedBox(height: 32),
            Consumer<BucketControlNotifier>(
              builder: (context, notifier, child) {
                return ElevatedButton(
                  onPressed: notifier.isLoading ? null : _saveExperimentId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: notifier.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Save Active Experiment', style: TextStyle(fontSize: 16)),
                );
              }
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            Text(
              'Current Active Experiment:',
              style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Consumer<BucketControlNotifier>(
              builder: (context, notifier, child) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    notifier.activeExperimentId ?? 'None (Auto-Resolve)',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                  ),
                );
              }
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 32),
            const Text(
              'System Control',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Perform administrative actions on the remote IoT device.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Consumer<BucketControlNotifier>(
              builder: (context, notifier, child) {
                final bool isRestarting = notifier.isLoading && notifier.sendingLabel == null;
                
                return InkWell(
                  onTap: notifier.isLoading ? null : () => _showRestartConfirmationDialog(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: notifier.isLoading ? Colors.grey : Colors.orange[800],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: isRestarting
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Restarting...',
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.restart_alt, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Restart System',
                                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Note: This will temporarily interrupt the video feed (~20s).',
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
}
