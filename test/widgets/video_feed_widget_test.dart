import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/widgets/video_feed_widget.dart';
import 'package:flutter_leafcloud_app/notifiers/ph_monitor_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([PHMonitorNotifier, BucketControlNotifier])
import 'video_feed_widget_test.mocks.dart';

void main() {
  late MockPHMonitorNotifier mockPhNotifier;
  late MockBucketControlNotifier mockBucketNotifier;

  setUp(() {
    mockPhNotifier = MockPHMonitorNotifier();
    mockBucketNotifier = MockBucketControlNotifier();
    
    when(mockPhNotifier.isMonitoring).thenReturn(false);
    when(mockBucketNotifier.activeBucketStatus).thenReturn('None');
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<PHMonitorNotifier>.value(value: mockPhNotifier),
          ChangeNotifierProvider<BucketControlNotifier>.value(value: mockBucketNotifier),
        ],
        child: const Scaffold(
          body: VideoFeedWidget(url: 'http://test.com'),
        ),
      ),
    );
  }

  group('VideoFeedWidget Mutual Exclusion', () {
    testWidgets('should show video when pH monitoring is inactive', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('Video feed paused'), findsNothing);
    });

    testWidgets('should show pause overlay when pH monitoring is active', (WidgetTester tester) async {
      when(mockPhNotifier.isMonitoring).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('Video feed paused'), findsOneWidget);
      expect(find.byIcon(Icons.pause_circle_outline), findsOneWidget);
    });
  });
}
