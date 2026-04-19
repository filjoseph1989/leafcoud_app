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
        child: MjpegView(
          uri: url,
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}
