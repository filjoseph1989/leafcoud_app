import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/widgets/video_feed_widget.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:mjpeg_view/mjpeg_view.dart';

import '../dashboard_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late BucketControlNotifier bucketControlNotifier;

  setUp(() {
    mockApiService = MockApiService();
    bucketControlNotifier = BucketControlNotifier(apiService: mockApiService);
  });

  testWidgets('VideoFeedWidget displays MjpegView with correct URL', (WidgetTester tester) async {
    const testUrl = 'http://localhost:8000/video_feed/';
    when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => 'None');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<BucketControlNotifier>.value(
            value: bucketControlNotifier,
            child: const VideoFeedWidget(url: testUrl),
          ),
        ),
      ),
    );

    expect(find.byType(MjpegView), findsOneWidget);
    final mjpegWidget = tester.widget<MjpegView>(find.byType(MjpegView));
    expect(mjpegWidget.uri, testUrl);
  });

  testWidgets('VideoFeedWidget displays active bucket overlay', (WidgetTester tester) async {
    const testUrl = 'http://localhost:8000/video_feed/';
    when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => 'NPK');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ChangeNotifierProvider<BucketControlNotifier>.value(
            value: bucketControlNotifier,
            child: const VideoFeedWidget(url: testUrl),
          ),
        ),
      ),
    );

    await bucketControlNotifier.fetchActiveBucketStatus();
    await tester.pump();

    expect(find.text('Active Bucket: NPK'), findsOneWidget);
  });
}
