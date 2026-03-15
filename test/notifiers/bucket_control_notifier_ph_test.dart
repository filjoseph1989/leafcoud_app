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

  group('BucketControlNotifier - pH Control', () {
    test('fetchActiveBucketStatus updates phUpdateRequested', () async {
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'NPK',
        'ph_update_requested': true,
      });

      await notifier.fetchActiveBucketStatus();

      expect(notifier.phUpdateRequested, isTrue);
      expect(notifier.activeBucketStatus, 'NPK');
    });

    test('togglePHSession calls requestPHUpdate when current state is false', () async {
      // Initial state is false
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'None',
        'ph_update_requested': false,
      });
      await notifier.fetchActiveBucketStatus();
      expect(notifier.phUpdateRequested, isFalse);

      when(mockApiService.requestPHUpdate()).thenAnswer((_) async => null);
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'None',
        'ph_update_requested': true,
      });

      await notifier.togglePHSession();

      verify(mockApiService.requestPHUpdate()).called(1);
      expect(notifier.phUpdateRequested, isTrue);
    });

    test('togglePHSession calls acknowledgePHUpdate when current state is true', () async {
      // Initial state is true
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'None',
        'ph_update_requested': true,
      });
      await notifier.fetchActiveBucketStatus();
      expect(notifier.phUpdateRequested, isTrue);

      when(mockApiService.acknowledgePHUpdate()).thenAnswer((_) async => null);
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'None',
        'ph_update_requested': false,
      });

      await notifier.togglePHSession();

      verify(mockApiService.acknowledgePHUpdate()).called(1);
      expect(notifier.phUpdateRequested, isFalse);
    });

    test('togglePHSession reverts state and sets error message on failure', () async {
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'None',
        'ph_update_requested': false,
      });
      await notifier.fetchActiveBucketStatus();
      
      when(mockApiService.requestPHUpdate()).thenThrow(Exception('Network Error'));

      await notifier.togglePHSession();

      expect(notifier.phUpdateRequested, isFalse);
      expect(notifier.errorMessage, contains('Network Error'));
    });

    test('stopPHSession calls acknowledgePHUpdate only if phUpdateRequested is true', () async {
      // Case 1: is true
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'None',
        'ph_update_requested': true,
      });
      await notifier.fetchActiveBucketStatus();
      
      when(mockApiService.acknowledgePHUpdate()).thenAnswer((_) async => null);
      await notifier.stopPHSession();
      verify(mockApiService.acknowledgePHUpdate()).called(1);

      // Case 2: is false
      when(mockApiService.fetchActiveBucketStatus()).thenAnswer((_) async => {
        'bucket_id': 'None',
        'ph_update_requested': false,
      });
      await notifier.fetchActiveBucketStatus();
      
      await notifier.stopPHSession();
      verifyNever(mockApiService.acknowledgePHUpdate());
    });
  });
}
