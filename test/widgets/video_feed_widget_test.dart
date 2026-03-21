import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/widgets/video_feed_widget.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([BucketControlNotifier])
import 'video_feed_widget_test.mocks.dart';

void main() {
  late MockBucketControlNotifier mockBucketNotifier;

  setUp(() {
    mockBucketNotifier = MockBucketControlNotifier();
    when(mockBucketNotifier.activeBucketStatus).thenReturn('None');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<BucketControlNotifier>.value(value: mockBucketNotifier),
        ],
        child: const Scaffold(
          body: VideoFeedWidget(url: 'http://test.com'),
        ),
      ),
    );
  }

  group('VideoFeedWidget', () {
    testWidgets('should show video feed', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.byType(VideoFeedWidget), findsOneWidget);
    });

    testWidgets('should show active bucket status', (WidgetTester tester) async {
      when(mockBucketNotifier.activeBucketStatus).thenReturn('NPK');
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('Active Bucket: NPK'), findsOneWidget);
    });
  });
}
