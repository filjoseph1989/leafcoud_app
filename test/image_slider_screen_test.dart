import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';
import 'package:flutter_leafcloud_app/notifiers/image_management_notifier.dart';
import 'package:flutter_leafcloud_app/image_slider_screen.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'image_slider_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;
  late ImageManagementNotifier imageManagementNotifier;

  setUp(() {
    mockApiService = MockApiService();
    imageManagementNotifier = ImageManagementNotifier(apiService: mockApiService);
  });

  testWidgets('ImageSliderScreen displays bucket label and reading ID in AppBar', (WidgetTester tester) async {
    final testImage = ImageInfo(
      filename: 'test.jpg',
      readingId: 123,
      timestamp: DateTime(2026, 3, 11, 22, 0, 0),
      bucketLabel: 'NPK',
      imageUrl: '/images/test.jpg',
    );

    // Populate the notifier with test data
    // We need to use reflection or a test-only method if _images is private
    // But in this project, ImageManagementNotifier doesn't have a public way to set images easily without fetch
    // So let's mock the fetchImages call
    when(mockApiService.fetchImages(skip: 0, limit: 20)).thenAnswer((_) async => [testImage]);
    when(mockApiService.baseUrl).thenReturn('http://localhost:8000');

    await imageManagementNotifier.fetchImages(refresh: true);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<ImageManagementNotifier>.value(
          value: imageManagementNotifier,
          child: const ImageSliderScreen(initialIndex: 0),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Expect to find "NPK - #123" in the title
    expect(find.text('NPK - #123'), findsOneWidget);
  });
}
