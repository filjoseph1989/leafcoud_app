import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import '../dashboard_screen_test.mocks.dart';

void main() {
  late MockApiService mockApiService;
  late BucketControlNotifier notifier;

  setUp(() {
    mockApiService = MockApiService();
    notifier = BucketControlNotifier(apiService: mockApiService);
  });

  group('BucketControlNotifier', () {
    test('initial state is correct', () {
      expect(notifier.activeBucketStatus, 'None');
      expect(notifier.activeExperimentId, isNull);
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
    });

    test('setExperimentId calls apiService and updates state', () async {
      when(mockApiService.postActiveExperiment('EXP-1')).thenAnswer((_) async => null);

      await notifier.setExperimentId('EXP-1');

      verify(mockApiService.postActiveExperiment('EXP-1')).called(1);
      expect(notifier.activeExperimentId, 'EXP-1');
      expect(notifier.isLoading, false);
    });

    test('setActiveBucket calls apiService and updates status', () async {
      when(mockApiService.postActiveBucket('NPK')).thenAnswer((_) async => null);
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'NPK',
        'ph_update_requested': false,
      });

      await notifier.setActiveBucket('NPK');

      verify(mockApiService.postActiveBucket('NPK')).called(1);
      verify(mockApiService.fetchActiveBucketStatus()).called(1);
      expect(notifier.activeBucketStatus, 'NPK');
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
    });

    test('setActiveBucket updates error on failure', () async {
      when(mockApiService.postActiveBucket('STOP')).thenThrow(Exception('API Error'));

      await notifier.setActiveBucket('STOP');

      expect(notifier.activeBucketStatus, 'None');
      expect(notifier.errorMessage, contains('Exception: API Error'));
    });

    test('fetchActiveBucketStatus updates state on success', () async {
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'Water',
        'ph_update_requested': false,
      });

      await notifier.fetchActiveBucketStatus();

      expect(notifier.activeBucketStatus, 'Water');
      expect(notifier.errorMessage, isNull);
    });

    test('polling updates status periodically', () async {
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'Mix',
        'ph_update_requested': false,
      });

      notifier.startPolling(interval: const Duration(milliseconds: 100));

      await Future.delayed(const Duration(milliseconds: 250));

      notifier.stopPolling();

      verify(mockApiService.fetchActiveBucketStatus()).called(greaterThanOrEqualTo(2));
      expect(notifier.activeBucketStatus, 'Mix');
    });
  });
}
