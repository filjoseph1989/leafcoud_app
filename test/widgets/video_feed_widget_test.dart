import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/widgets/video_feed_widget.dart';
import 'package:mjpeg_view/mjpeg_view.dart';

void main() {
  testWidgets('VideoFeedWidget displays MjpegView with correct URL', (WidgetTester tester) async {
    const testUrl = 'http://localhost:8000/video_feed';
    
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VideoFeedWidget(url: testUrl),
        ),
      ),
    );

    expect(find.byType(MjpegView), findsOneWidget);
    final mjpegWidget = tester.widget<MjpegView>(find.byType(MjpegView));
    expect(mjpegWidget.uri, testUrl);
  });
}
