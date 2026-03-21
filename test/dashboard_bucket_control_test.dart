import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/dashboard_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

import 'dashboard_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late SensorDataNotifier sensorDataNotifier;
  late BucketControlNotifier bucketControlNotifier;

  setUp(() {
    mockApiService = MockApiService();
    sensorDataNotifier = SensorDataNotifier(apiService: mockApiService);
    bucketControlNotifier = BucketControlNotifier(apiService: mockApiService);

    // Default mock behavior for initial sensor data fetch
    final mockData = SensorData(
      timestamp: DateTime.now(),
      sensors: {'ec': 1.0, 'ph': 6.0, 'temp_c': 20.0},
      predictions: {'n': 100, 'p': 50, 'k': 200},
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

  testWidgets('DashboardScreen displays simplified view', (WidgetTester tester) async {
    await tester.runAsync(() => setupWidget(tester));

    expect(find.text('Environment Metrics'), findsOneWidget);
    expect(find.text('Nutrient Analysis'), findsOneWidget);
    expect(find.text('System Health'), findsOneWidget);
    
    // Bucket Control should NO LONGER be on Dashboard
    expect(find.text('Bucket Control'), findsNothing);
    expect(find.text('Update pH'), findsNothing);

    await cleanupWidget(tester);
  });
}
