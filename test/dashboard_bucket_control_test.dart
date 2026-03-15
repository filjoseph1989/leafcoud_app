import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/dashboard_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/ph_monitor_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

import 'dashboard_screen_test.mocks.dart';
import 'widgets/video_feed_widget_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late SensorDataNotifier sensorDataNotifier;
  late BucketControlNotifier bucketControlNotifier;
  late PHMonitorNotifier phMonitorNotifier;

  setUp(() {
    mockApiService = MockApiService();
    sensorDataNotifier = SensorDataNotifier(apiService: mockApiService);
    bucketControlNotifier = BucketControlNotifier(apiService: mockApiService);
    phMonitorNotifier = PHMonitorNotifier(channelFactory: (_) => throw UnimplementedError());

    // Default mock behavior for initial sensor data fetch
    final mockData = SensorData(
      timestamp: DateTime.now(),
      sensors: {'ec': 1.0, 'ph': 6.0, 'temp_c': 20.0},
      status: 'Optimal',
    );
    when(mockApiService.fetchSensorData()).thenAnswer((_) async => mockData);
    when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
      'bucket_id': 'None',
      'ph_update_requested': false,
    });
  });

  tearDown(() {
    sensorDataNotifier.stopPolling();
    bucketControlNotifier.stopPolling();
    phMonitorNotifier.dispose();
  });

  Future<void> setupWidget(WidgetTester tester) async {
    // Set a very large surface size to ensure everything is "visible" without scrolling
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: sensorDataNotifier),
          ChangeNotifierProvider.value(value: bucketControlNotifier),
          ChangeNotifierProvider.value(value: phMonitorNotifier),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true, splashFactory: NoSplash.splashFactory),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump(); // Handle initState's post frame callback
    await tester.pump(const Duration(milliseconds: 100)); // Allow timers to start
  }

  Future<void> cleanupWidget(WidgetTester tester) async {
    // Clear the widget tree to stop timers and avoid pending timers error
    sensorDataNotifier.stopPolling();
    bucketControlNotifier.stopPolling();
    await tester.pumpWidget(Container());
    await tester.pump();
  }

  testWidgets('DashboardScreen displays bucket control buttons', (WidgetTester tester) async {
    await tester.runAsync(() => setupWidget(tester));

    expect(find.text('Bucket Control'), findsOneWidget);
    
    expect(find.widgetWithText(ElevatedButton, 'NPK'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Micro'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Mix'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Water'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Stop'), findsOneWidget);

    await cleanupWidget(tester);
  });

  testWidgets('Pressing NPK button calls setActiveBucket', (WidgetTester tester) async {
    await tester.runAsync(() => setupWidget(tester));
    
    when(mockApiService.postActiveBucket('NPK')).thenAnswer((_) async => null);

    await tester.tap(find.widgetWithText(ElevatedButton, 'NPK'));
    await tester.pump();

    verify(mockApiService.postActiveBucket('NPK')).called(1);

    await cleanupWidget(tester);
  });

  testWidgets('Pressing Stop button calls setActiveBucket', (WidgetTester tester) async {
    await tester.runAsync(() => setupWidget(tester));
    
    when(mockApiService.postActiveBucket('STOP')).thenAnswer((_) async => null);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Stop'));
    await tester.pump();

    verify(mockApiService.postActiveBucket('STOP')).called(1);

    await cleanupWidget(tester);
  });

  testWidgets('DashboardScreen displays "Start Live Probe" button initially', (WidgetTester tester) async {
    await tester.runAsync(() => setupWidget(tester));

    expect(find.text('Start Live Probe'), findsOneWidget);
    expect(find.text('LIVE'), findsNothing);

    await cleanupWidget(tester);
  });

  testWidgets('Pressing "Start Live Probe" calls togglePHSession', (WidgetTester tester) async {
    await tester.runAsync(() => setupWidget(tester));

    when(mockApiService.requestPHUpdate()).thenAnswer((_) async => null);

    await tester.tap(find.text('Start Live Probe'));
    await tester.pump();

    verify(mockApiService.requestPHUpdate()).called(1);

    await cleanupWidget(tester);
  });

  testWidgets('DashboardScreen displays "Stop Live Probe" and LIVE indicator when active', (WidgetTester tester) async {
    // Mock active state
    when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
      'bucket_id': 'None',
      'ph_update_requested': true,
    });
    // Mock sensor data with active state
    final mockData = SensorData(
      timestamp: DateTime.now(),
      sensors: {'ec': 1.0, 'ph': 6.5, 'temp_c': 20.0},
      status: 'Optimal',
      phUpdateRequested: true,
    );
    when(mockApiService.fetchSensorData()).thenAnswer((_) async => mockData);

    await tester.runAsync(() => setupWidget(tester));

    expect(find.text('Stop Live Probe'), findsOneWidget);
    expect(find.text('LIVE'), findsOneWidget);

    await cleanupWidget(tester);
  });

  testWidgets('Pressing "Start Live Probe" shows snackbar on failure', (WidgetTester tester) async {
    await tester.runAsync(() => setupWidget(tester));

    when(mockApiService.requestPHUpdate()).thenThrow(Exception('API Error'));

    await tester.tap(find.text('Start Live Probe'));
    await tester.pump(); // Start toggle
    await tester.pump(); // Handle error and show snackbar

    expect(find.textContaining('Error: Could not toggle probe'), findsOneWidget);

    await cleanupWidget(tester);
  });

  testWidgets('DashboardScreen calls stopPHSession on dispose if probe is active', (WidgetTester tester) async {
    final mockBucketNotifier = MockBucketControlNotifier();
    
    // Default stubs for mock notifier
    when(mockBucketNotifier.phUpdateRequested).thenReturn(true);
    when(mockBucketNotifier.activeBucketStatus).thenReturn('None');
    when(mockBucketNotifier.isLoading).thenReturn(false);
    when(mockBucketNotifier.errorMessage).thenReturn(null);
    when(mockBucketNotifier.stopPHSession()).thenAnswer((_) async => null);

    // Set a very large surface size to ensure everything is "visible" without scrolling
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SensorDataNotifier>.value(value: sensorDataNotifier),
          ChangeNotifierProvider<BucketControlNotifier>.value(value: mockBucketNotifier),
          ChangeNotifierProvider<PHMonitorNotifier>.value(value: phMonitorNotifier),
        ],
        child: MaterialApp(
          theme: ThemeData(useMaterial3: true),
          home: const DashboardScreen(),
        ),
      ),
    );
    await tester.pump();

    // Stop polling to avoid pending timers
    sensorDataNotifier.stopPolling();
    phMonitorNotifier.disconnect();

    // Trigger cleanup (dispose)
    await tester.pumpWidget(Container());
    await tester.pump();

    verify(mockBucketNotifier.stopPHSession()).called(1);
  });
}
