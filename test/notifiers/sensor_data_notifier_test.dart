import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/notifiers/sensor_data_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

import 'sensor_data_notifier_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late SensorDataNotifier notifier;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    notifier = SensorDataNotifier(apiService: mockApiService);
  });

  group('SensorDataNotifier', () {
    test('initial state is correct', () {
      expect(notifier.data, isNull);
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
    });

    test('fetchSensorData updates data on success', () async {
      final mockData = SensorData(
        timestamp: DateTime.parse('2026-03-01T10:00:00Z'),
        sensors: {'ec': 1.5, 'ph': 6.8, 'temp_c': 25.0},
        status: 'ok',
      );

      when(mockApiService.fetchSensorData()).thenAnswer((_) async => mockData);

      final future = notifier.fetchSensorData();
      expect(notifier.isLoading, true);

      await future;

      expect(notifier.isLoading, false);
      expect(notifier.data, mockData);
      expect(notifier.errorMessage, isNull);
    });

    test('fetchSensorData updates error on failure', () async {
      when(mockApiService.fetchSensorData()).thenThrow(Exception('Failed to load data'));

      await notifier.fetchSensorData();

      expect(notifier.isLoading, false);
      expect(notifier.data, isNull);
      expect(notifier.errorMessage, contains('Exception: Failed to load data'));
    });

    test('startPolling calls fetchSensorData periodically', () async {
      final mockData = SensorData(
        timestamp: DateTime.now(),
        sensors: {'ec': 1.5, 'ph': 6.8, 'temp_c': 25.0},
        status: 'ok',
      );

      when(mockApiService.fetchSensorData()).thenAnswer((_) async => mockData);

      notifier.startPolling(interval: const Duration(milliseconds: 100));
      
      await Future.delayed(const Duration(milliseconds: 250));
      
      notifier.stopPolling();
      
      verify(mockApiService.fetchSensorData()).called(greaterThanOrEqualTo(2));
    });
  });
}
