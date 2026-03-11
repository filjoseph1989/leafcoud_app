import 'package:flutter/material.dart' hide ImageInfo;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/models/image_info.dart';
import 'package:flutter_leafcloud_app/widgets/image_grid_item.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('ImageGridItem displays bucket label and reading ID', (WidgetTester tester) async {
    final testImage = ImageInfo(
      filename: 'test.jpg',
      readingId: 123,
      timestamp: DateTime(2026, 3, 11, 22, 0, 0),
      bucketLabel: 'NPK',
      imageUrl: '/images/test.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridView.count(
            crossAxisCount: 2,
            children: [
              ImageGridItem(
                image: testImage,
                baseUrl: 'http://localhost:8000',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // Expect to find "NPK - #123"
    expect(find.text('NPK - #123'), findsOneWidget);
    
    // Expect to find formatted date
    final formattedDate = DateFormat.yMMMd().add_jm().format(testImage.timestamp!);
    expect(find.text(formattedDate), findsOneWidget);
  });

  testWidgets('ImageGridItem displays "Reading" and no ID when metadata is null', (WidgetTester tester) async {
    final testImage = ImageInfo(
      filename: 'test.jpg',
      readingId: null,
      timestamp: null,
      bucketLabel: null,
      imageUrl: '/images/test.jpg',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GridView.count(
            crossAxisCount: 2,
            children: [
              ImageGridItem(
                image: testImage,
                baseUrl: 'http://localhost:8000',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    // Expect to find "Reading"
    expect(find.text('Reading'), findsOneWidget);
    
    // Expect to find "Unknown"
    expect(find.text('Unknown'), findsOneWidget);
  });
}
