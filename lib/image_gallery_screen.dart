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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text('Image Gallery', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: theme.colorScheme.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.colorScheme.primary),
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
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_off_rounded, size: 80, color: theme.colorScheme.primary.withOpacity(0.2)),
                    const SizedBox(height: 24),
                    Text(
                      'Load Failed',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notifier.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => notifier.fetchImages(refresh: true),
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (notifier.images.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 80, color: theme.colorScheme.primary.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text('No images found', style: theme.textTheme.bodyLarge),
                ],
              ),
            );
          }

          final baseUrl = notifier.apiService.baseUrl;

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
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
