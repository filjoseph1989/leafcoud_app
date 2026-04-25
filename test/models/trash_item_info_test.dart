import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/models/trash_item_info.dart';

void main() {
  group('TrashItemInfo', () {
    test('should correctly parse from JSON', () {
      final json = {
        'id': 1,
        'filename': 'reading_Water_20260415_120000.jpg',
        'reason': 'low_greenness',
        'metric_value': 34.5,
        'timestamp': '2026-04-15T12:00:00Z',
        'image_url': '/images/trash/1.jpg',
      };

      final trashItem = TrashItemInfo.fromJson(json);

      expect(trashItem.id, 1);
      expect(trashItem.filename, 'reading_Water_20260415_120000.jpg');
      expect(trashItem.reason, 'low_greenness');
      expect(trashItem.metricValue, 34.5);
      expect(trashItem.timestamp, DateTime.parse('2026-04-15T12:00:00Z'));
      expect(trashItem.imageUrl, '/images/trash/1.jpg');
    });

    test('should handle null metric_value by defaulting to 0.0', () {
      final json = {
        'id': 1,
        'filename': 'test.jpg',
        'reason': 'test',
        'metric_value': null,
        'timestamp': '2026-04-15T12:00:00Z',
      };

      final trashItem = TrashItemInfo.fromJson(json);
      expect(trashItem.metricValue, 0.0);
    });

    test('should correctly convert to JSON', () {
      final timestamp = DateTime.parse('2026-04-15T12:00:00Z');
      final trashItem = TrashItemInfo(
        id: 1,
        filename: 'reading_Water_20260415_120000.jpg',
        reason: 'low_greenness',
        metricValue: 34.5,
        timestamp: timestamp,
        imageUrl: '/images/trash/1.jpg',
      );

      final json = trashItem.toJson();

      expect(json['id'], 1);
      expect(json['filename'], 'reading_Water_20260415_120000.jpg');
      expect(json['reason'], 'low_greenness');
      expect(json['metric_value'], 34.5);
      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['image_url'], '/images/trash/1.jpg');
    });
  });
}
