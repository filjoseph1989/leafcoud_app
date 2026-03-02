import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/notifiers/bucket_control_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';

import 'bucket_control_notifier_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late BucketControlNotifier notifier;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    notifier = BucketControlNotifier(apiService: mockApiService);
  });

  group('BucketControlNotifier', () {
    test('initial state is correct', () {
      expect(notifier.activeBucketStatus, 'None');
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
    });

    test('setActiveBucket calls apiService and updates status', () async {
      when(mockApiService.postActiveBucket('NPK')).thenAnswer((_) async => null);
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => 'NPK');

      await notifier.setActiveBucket('NPK');

      verify(mockApiService.postActiveBucket('NPK')).called(1);
      expect(notifier.activeBucketStatus, 'NPK');
    });

    test('fetchActiveBucketStatus updates state on success', () async {
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => 'Water');

      await notifier.fetchActiveBucketStatus();

      expect(notifier.activeBucketStatus, 'Water');
      expect(notifier.errorMessage, isNull);
    });

    test('fetchActiveBucketStatus updates error on failure', () async {
      when(mockApiService.fetchActiveBucketStatus()).thenThrow(Exception('Failed to fetch status'));

      await notifier.fetchActiveBucketStatus();

      expect(notifier.errorMessage, contains('Exception: Failed to fetch status'));
    });

    test('polling updates status periodically', () async {
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => 'Mix');

      notifier.startPolling(interval: const Duration(milliseconds: 100));

      await Future.delayed(const Duration(milliseconds: 250));

      notifier.stopPolling();

      verify(mockApiService.fetchActiveBucketStatus()).called(greaterThanOrEqualTo(2));
      expect(notifier.activeBucketStatus, 'Mix');
    });
  });
}
