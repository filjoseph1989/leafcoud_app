import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_leafcloud_app/models/image_info.dart';
import 'package:intl/intl.dart';

class ImageGridItem extends StatelessWidget {
  final ImageInfo image;
  final String baseUrl;
  final VoidCallback onTap;

  const ImageGridItem({
    super.key,
    required this.image,
    required this.baseUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fullImageUrl = baseUrl + image.imageUrl;
    final String formattedDate = image.timestamp != null 
        ? DateFormat.yMMMd().add_jm().format(image.timestamp!) 
        : 'Unknown';

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              fullImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.broken_image, color: Colors.grey),
              ),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withAlpha(180), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${image.bucketLabel ?? 'Reading'}${image.readingId != null ? ' - #${image.readingId}' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (image.isOrphaned)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.warning, color: Colors.orange, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}
