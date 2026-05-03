import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/notifiers/trash_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/trash_item_info.dart';

import 'trash_notifier_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late TrashNotifier notifier;
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    notifier = TrashNotifier(apiService: mockApiService);
  });

  group('TrashNotifier', () {
    test('initial state is correct', () {
      expect(notifier.items, isEmpty);
      expect(notifier.isLoading, false);
      expect(notifier.errorMessage, isNull);
      expect(notifier.hasMore, true);
    });

    test('fetchTrashItems updates items on success', () async {
      final mockItems = [
        TrashItemInfo(
          id: 1,
          filename: 'img1.jpg',
          reason: 'low_greenness',
          metricValue: 10.0,
          timestamp: DateTime.now(),
        ),
      ];

      when(mockApiService.getTrashItems(skip: 0, limit: 20))
          .thenAnswer((_) async => mockItems);

      final future = notifier.fetchTrashItems();
      expect(notifier.isLoading, true);

      await future;

      expect(notifier.isLoading, false);
      expect(notifier.items, mockItems);
      expect(notifier.errorMessage, isNull);
    });

    test('restoreItem removes item on success', () async {
      final item = TrashItemInfo(
        id: 1,
        filename: 'img1.jpg',
        reason: 'test',
        metricValue: 1.0,
        timestamp: DateTime.now(),
      );
      
      when(mockApiService.getTrashItems(skip: 0, limit: 20))
          .thenAnswer((_) async => [item]);
      await notifier.fetchTrashItems();
      expect(notifier.items, contains(item));

      when(mockApiService.restoreImage(1)).thenAnswer((_) async {});

      await notifier.restoreItem(1);

      expect(notifier.items, isEmpty);
      expect(notifier.errorMessage, isNull);
    });

    test('deleteItem removes item on success', () async {
      final item = TrashItemInfo(
        id: 1,
        filename: 'img1.jpg',
        reason: 'test',
        metricValue: 1.0,
        timestamp: DateTime.now(),
      );
      
      when(mockApiService.getTrashItems(skip: 0, limit: 20))
          .thenAnswer((_) async => [item]);
      await notifier.fetchTrashItems();
      expect(notifier.items, contains(item));

      when(mockApiService.deleteImage('img1.jpg', id: 1)).thenAnswer((_) async {});

      await notifier.deleteItem('img1.jpg', 1);

      expect(notifier.items, isEmpty);
      expect(notifier.errorMessage, isNull);
    });
  });
}
