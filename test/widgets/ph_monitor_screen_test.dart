import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/notifiers/ph_monitor_notifier.dart';
import 'package:flutter_leafcloud_app/ph_monitor_screen.dart';
import 'package:flutter_leafcloud_app/models/ph_sensor_data.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

@GenerateMocks([PHMonitorNotifier])
import 'ph_monitor_screen_test.mocks.dart';

void main() {
  late MockPHMonitorNotifier mockNotifier;

  setUp(() {
    mockNotifier = MockPHMonitorNotifier();
    when(mockNotifier.isConnected).thenReturn(false);
    when(mockNotifier.readings).thenReturn([]);
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: ChangeNotifierProvider<PHMonitorNotifier>.value(
        value: mockNotifier,
        child: const PHMonitorScreen(),
      ),
    );
  }

  group('PHMonitorScreen', () {
    testWidgets('should show disconnected status initially', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Status: Disconnected'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should show connected status when notifier is connected', (WidgetTester tester) async {
      when(mockNotifier.isConnected).thenReturn(true);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Status: Connected'), findsOneWidget);
    });

    testWidgets('should display readings in the list', (WidgetTester tester) async {
      final readings = [
        PHSensorData(
          timestamp: DateTime.parse('2026-03-14T12:00:00Z'),
          rawAdc: 15000,
          voltage: 2.5,
          deviceId: 'TEST_PI',
        ),
      ];
      when(mockNotifier.readings).thenReturn(readings);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('TEST_PI'), findsOneWidget);
      expect(find.textContaining('15000'), findsOneWidget);
      expect(find.textContaining('2.5'), findsOneWidget);
    });
  });
}
