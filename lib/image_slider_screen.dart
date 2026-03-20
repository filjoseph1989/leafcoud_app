import 'package:flutter/material.dart' hide ImageInfo;
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/notifiers/image_management_notifier.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';
import 'package:intl/intl.dart';

class ImageSliderScreen extends StatefulWidget {
  final int initialIndex;

  const ImageSliderScreen({super.key, required this.initialIndex});

  @override
  State<ImageSliderScreen> createState() => _ImageSliderScreenState();
}

class _ImageSliderScreenState extends State<ImageSliderScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, ImageInfo image) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              navigator.pop();
              try {
                final notifier = context.read<ImageManagementNotifier>();
                final imagesCount = notifier.images.length;
                
                await notifier.deleteImage(image);
                
                if (imagesCount <= 1) {
                  if (mounted) navigator.pop();
                } else {
                  // If we deleted the last one, go to the new last one
                  if (_currentIndex >= notifier.images.length) {
                    setState(() {
                      _currentIndex = notifier.images.length - 1;
                    });
                    _pageController.jumpToPage(_currentIndex);
                  }
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ImageManagementNotifier>(
      builder: (context, notifier, child) {
        if (notifier.images.isEmpty) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
            backgroundColor: Colors.black,
            body: const Center(child: Text('No images available', style: TextStyle(color: Colors.white))),
          );
        }

        final image = notifier.images[_currentIndex];
        final String formattedDate = image.timestamp != null 
            ? DateFormat.yMMMd().add_jm().format(image.timestamp!) 
            : 'Unknown';

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${image.bucketLabel ?? 'Reading'}${image.readingId != null ? ' - #${image.readingId}' : ''}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, image),
              ),
            ],
          ),
          body: PageView.builder(
            controller: _pageController,
            itemCount: notifier.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              if (index >= notifier.images.length - 5) {
                notifier.fetchImages();
              }
            },
            itemBuilder: (context, index) {
              final img = notifier.images[index];
              final fullUrl = notifier.apiService.baseUrl + img.imageUrl;
              
              return InteractiveViewer(
                child: Image.network(
                  fullUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 64),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
