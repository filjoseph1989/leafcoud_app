import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

void main() {
  group('SensorData', () {
    test('should correctly parse from JSON', () {
      final json = {
        'timestamp': '2026-03-01T14:30:00Z',
        'plant_id': 'bucket_1',
        'sensors': {
          'temp_c': 22.5,
          'ec': 1.2,
          'ph': 6.5,
        },
        'status': 'Optimal',
      };

      final sensorData = SensorData.fromJson(json);

      expect(sensorData.timestamp, DateTime.parse('2026-03-01T14:30:00Z'));
      expect(sensorData.plantId, 'bucket_1');
      expect(sensorData.sensors!['temp_c'], 22.5);
      expect(sensorData.status, 'Optimal');
    });

    test('should correctly convert to JSON', () {
      final timestamp = DateTime.parse('2026-03-01T14:30:00Z');
      final sensorData = SensorData(
        timestamp: timestamp,
        plantId: 'bucket_1',
        sensors: {'temp_c': 22.5},
      );

      final json = sensorData.toJson();

      expect(json['timestamp'], timestamp.toIso8601String());
      expect(json['plant_id'], 'bucket_1');
      expect(json['sensors']['temp_c'], 22.5);
    });
  });
}
