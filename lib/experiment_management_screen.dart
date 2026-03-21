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
          ],
        ),
      ),
    );
  }
}
