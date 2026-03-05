import 'package:flutter/material.dart' hide ImageInfo;
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/notifiers/image_management_notifier.dart';
import 'package:flutter_leafcloud_app/widgets/image_grid_item.dart';
import 'package:flutter_leafcloud_app/image_slider_screen.dart';

class ImageGalleryScreen extends StatefulWidget {
  const ImageGalleryScreen({super.key});

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ImageManagementNotifier>().fetchImages(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<ImageManagementNotifier>().fetchImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Gallery'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ImageManagementNotifier>().fetchImages(refresh: true),
          ),
        ],
      ),
      body: Consumer<ImageManagementNotifier>(
        builder: (context, notifier, child) {
          if (notifier.isLoading && notifier.images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notifier.errorMessage != null && notifier.images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(notifier.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => notifier.fetchImages(refresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notifier.images.isEmpty) {
            return const Center(child: Text('No images found.'));
          }

          final baseUrl = notifier.apiService.baseUrl;

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: notifier.images.length + (notifier.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == notifier.images.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final image = notifier.images[index];
              return ImageGridItem(
                image: image,
                baseUrl: baseUrl,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ImageSliderScreen(initialIndex: index),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
