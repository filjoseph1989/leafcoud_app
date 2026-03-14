import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/notifiers/ph_monitor_notifier.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:async';

@GenerateMocks([WebSocketChannel, WebSocketSink])
import 'ph_monitor_notifier_test.mocks.dart';

void main() {
  late PHMonitorNotifier notifier;
  late MockWebSocketChannel mockChannel;
  late MockWebSocketSink mockSink;
  late StreamController streamController;

  setUp(() {
    mockChannel = MockWebSocketChannel();
    mockSink = MockWebSocketSink();
    streamController = StreamController.broadcast();

    when(mockChannel.sink).thenReturn(mockSink);
    when(mockChannel.stream).thenAnswer((_) => streamController.stream);

    notifier = PHMonitorNotifier(
      channelFactory: (url) => mockChannel,
    );
  });

  tearDown(() {
    streamController.close();
  });

  group('PHMonitorNotifier', () {
    test('initial state should be disconnected', () {
      expect(notifier.isConnected, false);
      expect(notifier.readings, isEmpty);
    });

    test('should update connection status when connected', () async {
      notifier.connect('ws://localhost:8000');
      // In a real scenario, the connection status might change asynchronously.
      // For this test, we assume the notifier updates its state immediately or after a short delay.
      expect(notifier.isConnected, true);
    });

    test('should add readings when data is received via WebSocket', () async {
      notifier.connect('ws://localhost:8000');

      final readingJson = '{"device_id": "TEST_PI", "readings": [{"timestamp": "2026-03-14T12:00:00Z", "raw_adc": 20000, "voltage": 3.0}]}';
      streamController.add(readingJson);

      // Wait for the stream to process
      await Future.delayed(Duration(milliseconds: 100));

      expect(notifier.readings, isNotEmpty);
      expect(notifier.readings.first.deviceId, 'TEST_PI');
      expect(notifier.readings.first.rawAdc, 20000);
    });

    test('should update connection status when connection is closed', () async {
      notifier.connect('ws://localhost:8000');
      expect(notifier.isConnected, true);

      await streamController.close();
      // Wait for the notifier to react to stream closure
      await Future.delayed(Duration(milliseconds: 100));

      expect(notifier.isConnected, false);
    });
  });
}
