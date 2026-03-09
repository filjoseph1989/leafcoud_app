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

  group('BucketControlNotifier.restartIot', () {
    test('restartIot calls apiService and updates state on success', () async {
      when(mockApiService.restartIot()).thenAnswer((_) async => null);

      final future = notifier.restartIot();
      
      // Should be loading immediately
      expect(notifier.isLoading, true);
      
      await future;

      verify(mockApiService.restartIot()).called(1);
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
    });

    test('restartIot updates error on failure', () async {
      when(mockApiService.restartIot()).thenThrow(Exception('Restart failed'));

      await notifier.restartIot();

      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, contains('Exception: Restart failed'));
    });
  });
}
