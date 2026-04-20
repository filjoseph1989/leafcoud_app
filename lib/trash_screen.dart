import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/notifiers/trash_notifier.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TrashNotifier>().fetchTrashItems();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TrashNotifier>().fetchTrashItems();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Trash', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Consumer<TrashNotifier>(
        builder: (context, notifier, child) {
          // Listen for errors and show snackbar
          if (notifier.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(notifier.errorMessage!)),
              );
              notifier.clearError();
            });
          }

          if (notifier.isLoading && notifier.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.items.isEmpty && !notifier.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete_outline_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text('Trash is empty', style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            itemCount: notifier.items.length + (notifier.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == notifier.items.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final item = notifier.items[index];
              return ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(item.filename),
                subtitle: Text('Reason: ${item.reason}'),
                trailing: Text('${item.metricValue.toStringAsFixed(1)}'),
              );
            },
          );
        },
      ),
    );
  }
}
