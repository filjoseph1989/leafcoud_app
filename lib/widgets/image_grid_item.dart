import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_leafcloud_app/models/image_info.dart';
import 'package:intl/intl.dart';

class ImageGridItem extends StatelessWidget {
  final ImageInfo image;
  final String baseUrl;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const ImageGridItem({
    super.key,
    required this.image,
    required this.baseUrl,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fullImageUrl = baseUrl + image.imageUrl;
    final String formattedDate = image.timestamp != null 
        ? DateFormat.yMMMd().add_jm().format(image.timestamp!) 
        : 'Unknown';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                fullImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: theme.colorScheme.surface,
                  child: const Center(
                    child: Icon(Icons.broken_image_rounded, color: Colors.grey),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: theme.colorScheme.surface,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Colors.black.withOpacity(0.7), Colors.transparent],
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
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (image.isOrphaned)
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 16),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
