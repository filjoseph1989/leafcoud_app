import 'dart:async';
import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_leafcloud_app/image_gallery_screen.dart';
import 'package:flutter_leafcloud_app/notifiers/image_management_notifier.dart';
import 'package:flutter_leafcloud_app/widgets/image_grid_item.dart';
import 'package:flutter_leafcloud_app/services/api_service.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';

import 'image_gallery_screen_test.mocks.dart';

@GenerateMocks([ApiService])
void main() {
  late MockApiService mockApiService;

  setUp(() {
    mockApiService = MockApiService();
    when(mockApiService.baseUrl).thenReturn('http://test.com');
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ImageGalleryScreen shows loading and then images', (WidgetTester tester) async {
    final images = [
      ImageInfo(filename: 'test1.jpg', imageUrl: '/test1.jpg'),
      ImageInfo(filename: 'test2.jpg', imageUrl: '/test2.jpg'),
    ];

    final completer = Completer<List<ImageInfo>>();
    when(mockApiService.fetchImages(skip: 0, limit: 50)).thenAnswer((_) => completer.future);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ImageManagementNotifier(apiService: mockApiService),
          ),
        ],
        child: const MaterialApp(home: ImageGalleryScreen()),
      ),
    );

    await tester.pump(); 
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    completer.complete(images);
    
    // Use pump repeatedly instead of pumpAndSettle because of infinite animations in ImageGridItem
    for(int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('Image Gallery'), findsOneWidget);
    expect(find.byType(ImageGridItem), findsNWidgets(2));
  });
}
