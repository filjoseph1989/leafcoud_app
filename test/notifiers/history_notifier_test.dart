import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/notifiers/history_notifier.dart';
import '../dashboard_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late HistoryNotifier notifier;

  setUp(() {
    mockApiService = MockApiService();
    notifier = HistoryNotifier(apiService: mockApiService);
  });

  group('HistoryNotifier', () {
    test('initial state is correct', () {
      expect(notifier.experimentId, isNull);
      expect(notifier.historyData, isEmpty);
      expect(notifier.availableBuckets, isEmpty);
      expect(notifier.selectedBucket, isNull);
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
    });

    test('fetchHistory updates state on success', () async {
      final mockResponse = {
        'experiment_id': '123',
        'history': {
          'NPK': [
            {'timestamp': '2026-03-01T10:00:00Z', 'n_ppm': 100.0}
          ]
        }
      };

      when(mockApiService.fetchExperimentHistory('123'))
          .thenAnswer((_) async => mockResponse);

      await notifier.fetchHistory('123');

      expect(notifier.experimentId, '123');
      expect(notifier.historyData, isNotEmpty);
      expect(notifier.availableBuckets, contains('NPK'));
      expect(notifier.selectedBucket, 'NPK');
      expect(notifier.currentBucketData.first.nitrogen, 100.0);
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
    });

    test('fetchHistory updates error on failure', () async {
      when(mockApiService.fetchExperimentHistory('EXP-FAIL'))
          .thenThrow(Exception('Fetch Failed'));

      await notifier.fetchHistory('EXP-FAIL');

      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, contains('Exception: Fetch Failed'));
      expect(notifier.experimentId, isNull);
    });
  });
}
