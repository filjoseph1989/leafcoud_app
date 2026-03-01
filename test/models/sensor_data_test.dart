import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

void main() {
  group('SensorData', () {
    test('should correctly parse from JSON', () {
      final json = {
        'temperature': 22.5,
        'ec': 1.2,
        'ph': 6.5,
        'status': 'active',
        'timestamp': '2026-03-01T14:30:00Z',
      };

      final sensorData = SensorData.fromJson(json);

      expect(sensorData.temperature, 22.5);
      expect(sensorData.ec, 1.2);
      expect(sensorData.ph, 6.5);
      expect(sensorData.status, 'active');
      expect(sensorData.timestamp, DateTime.parse('2026-03-01T14:30:00Z'));
    });

    test('should correctly convert to JSON', () {
      final timestamp = DateTime.parse('2026-03-01T14:30:00Z');
      final sensorData = SensorData(
        temperature: 22.5,
        ec: 1.2,
        ph: 6.5,
        status: 'active',
        timestamp: timestamp,
      );

      final json = sensorData.toJson();

      expect(json['temperature'], 22.5);
      expect(json['ec'], 1.2);
      expect(json['ph'], 6.5);
      expect(json['status'], 'active');
      expect(json['timestamp'], timestamp.toIso8601String());
    });
  });
}
