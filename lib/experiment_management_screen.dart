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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Experiment Management', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Set Active Experiment',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'This ID links sensor data to a specific experiment on the server for accurate traceability.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _experimentIdController,
              decoration: const InputDecoration(
                hintText: 'e.g., EXP-NPK-BATCH1',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
            const SizedBox(height: 32),
            Consumer<BucketControlNotifier>(
              builder: (context, notifier, child) {
                return SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: notifier.isLoading ? null : _saveExperimentId,
                    child: notifier.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save Active Experiment'),
                  ),
                );
              }
            ),
            const SizedBox(height: 40),
            Text(
              'Current Status',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Consumer<BucketControlNotifier>(
              builder: (context, notifier, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active Experiment ID',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          notifier.activeExperimentId ?? 'None (Auto-Resolve)',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
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
