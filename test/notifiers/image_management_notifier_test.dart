import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_leafcloud_app/notifiers/image_management_notifier.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';

import 'image_management_notifier_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late ImageManagementNotifier notifier;

  setUp(() {
    mockApiService = MockApiService();
    notifier = ImageManagementNotifier(apiService: mockApiService);
  });

  group('ImageManagementNotifier', () {
    test('fetchImages updates images and handles pagination', () async {
      final image1 = ImageInfo(filename: 'img1.jpg', imageUrl: '/img1.jpg');
      
      when(mockApiService.fetchImages(skip: 0, limit: 20))
          .thenAnswer((_) async => [image1]);

      await notifier.fetchImages(refresh: true);

      expect(notifier.images.length, 1);
      expect(notifier.images[0].filename, 'img1.jpg');
      expect(notifier.hasMore, false); // Less than limit (20)
    });

    test('fetchImages handles errors', () async {
      when(mockApiService.fetchImages(skip: 0, limit: 20))
          .thenThrow(Exception('API Error'));

      await notifier.fetchImages(refresh: true);

      expect(notifier.errorMessage, contains('API Error'));
      expect(notifier.images.isEmpty, true);
    });

    test('deleteImage removes image from list', () async {
      final image1 = ImageInfo(filename: 'img1.jpg', imageUrl: '/img1.jpg');
      
      when(mockApiService.fetchImages(skip: 0, limit: 20))
          .thenAnswer((_) async => [image1]);
      when(mockApiService.deleteImage('img1.jpg')).thenAnswer((_) async => null);

      await notifier.fetchImages(refresh: true);
      expect(notifier.images.length, 1);

      await notifier.deleteImage(image1);
      expect(notifier.images.length, 0);
    });
  });
}
