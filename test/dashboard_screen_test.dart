import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/dashboard_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

import 'dashboard_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
  });

  testWidgets('DashboardScreen shows loading indicator initially', (WidgetTester tester) async {
    // Provide a completion for the initial fetch that startPolling will trigger
    when(mockApiService.fetchSensorData()).thenAnswer((_) async => Completer<SensorData>().future);
    when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
      'bucket_id': 'None',
      'ph_update_requested': false,
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => SensorDataNotifier(apiService: mockApiService),
          ),
          ChangeNotifierProvider(
            create: (_) => BucketControlNotifier(apiService: mockApiService),
          ),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    // Initial build might show "No data available" if pump happens before startPolling's notify
    // but startPolling is in addPostFrameCallback.
    
    await tester.pump(); // Handle post frame callback

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
