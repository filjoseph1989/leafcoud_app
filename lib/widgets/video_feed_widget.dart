import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mjpeg_view/mjpeg_view.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';

class VideoFeedWidget extends StatelessWidget {
  final String url;

  const VideoFeedWidget({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Stack(
          children: [
            MjpegView(
              uri: url,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
            Positioned(
              top: 12,
              left: 12,
              child: Consumer<BucketControlNotifier>(
                builder: (context, notifier, child) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(120),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: notifier.activeBucketStatus == 'None' 
                                ? Colors.grey 
                                : Colors.greenAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Active Bucket: ${notifier.activeBucketStatus}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
