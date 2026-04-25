import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/trash_review_item.dart';

class TrashReviewScreen extends StatefulWidget {
  const TrashReviewScreen({super.key});

  @override
  State<TrashReviewScreen> createState() => _TrashReviewScreenState();
}

class _TrashReviewScreenState extends State<TrashReviewScreen> {
  TrashReviewItem? _currentItem;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNextItem();
  }

  Future<void> _fetchNextItem() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final item = await apiService.getTrashReviewNext();
      setState(() {
        _currentItem = item;
        _isLoading = false;
      });
      // Automatically mark as viewed once loaded
      _markAsViewed(item.id);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().contains('No more images') 
            ? 'No more images to review' 
            : e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchItemAtOffset(int offset) async {
    if (offset < 0) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final apiService = context.read<ApiService>();
      final item = await apiService.getTrashReviewScan(offset);
      setState(() {
        _currentItem = item;
        _isLoading = false;
      });
      _markAsViewed(item.id);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsViewed(int id) async {
    try {
      final apiService = context.read<ApiService>();
      await apiService.markTrashViewed(id);
    } catch (e) {
      debugPrint('Failed to mark item $id as viewed: $e');
    }
  }

  Future<void> _restoreItem() async {
    if (_currentItem == null) return;

    try {
      final apiService = context.read<ApiService>();
      await apiService.restoreTrash(_currentItem!.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item restored successfully'), backgroundColor: Colors.green),
        );
      }
      _fetchNextItem();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to restore item: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Trash Review', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNextItem,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green[300]),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.white, fontSize: 18)),
                      const SizedBox(height: 24),
                      ElevatedButton(onPressed: _fetchNextItem, child: const Text('Retry / Refresh')),
                    ],
                  ),
                )
              : _currentItem == null
                  ? const Center(child: Text('No items to review', style: TextStyle(color: Colors.white)))
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Item ${_currentItem!.currentIndex + 1} of ${_currentItem!.totalCount}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: _currentItem!.imageUrl != null
                                ? Image.network(
                                    _currentItem!.imageUrl!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const Icon(
                                      Icons.broken_image,
                                      size: 100,
                                      color: Colors.white24,
                                    ),
                                  )
                                : const Icon(Icons.image_not_supported, size: 100, color: Colors.white24),
                          ),
                        ),
                        _buildControls(theme),
                      ],
                    ),
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Reason: ${_currentItem?.reason ?? "Unknown"}',
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Filename: ${_currentItem?.filename ?? "Unknown"}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                onPressed: (_currentItem != null && _currentItem!.currentIndex > 0)
                    ? () => _fetchItemAtOffset(_currentItem!.currentIndex - 1)
                    : null,
                icon: Icons.skip_previous,
                label: 'Previous',
                color: Colors.blueGrey,
              ),
              _buildActionButton(
                onPressed: _fetchNextItem,
                icon: Icons.skip_next,
                label: 'Skip',
                color: Colors.orange,
              ),
              _buildActionButton(
                onPressed: _restoreItem,
                icon: Icons.restore,
                label: 'Restore',
                color: Colors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: onPressed,
          icon: Icon(icon, size: 28),
          padding: const EdgeInsets.all(16),
          style: IconButton.styleFrom(
            backgroundColor: onPressed == null ? Colors.grey[800] : color,
            disabledBackgroundColor: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label, 
          style: TextStyle(
            color: onPressed == null ? Colors.white24 : Colors.white, 
            fontSize: 14
          ),
        ),
      ],
    );
  }
}
