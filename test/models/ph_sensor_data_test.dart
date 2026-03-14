import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/models/ph_sensor_data.dart';

void main() {
  group('PHSensorData', () {
    test('should create PHSensorData from JSON', () {
      final json = {
        'timestamp': '2026-03-14T12:00:00Z',
        'raw_adc': 15000,
        'voltage': 2.5,
        'device_id': 'ADS1115_Pi',
      };

      final data = PHSensorData.fromJson(json);

      expect(data.timestamp, DateTime.parse('2026-03-14T12:00:00Z'));
      expect(data.rawAdc, 15000);
      expect(data.voltage, 2.5);
      expect(data.deviceId, 'ADS1115_Pi');
    });

    test('should convert PHSensorData to JSON', () {
      final data = PHSensorData(
        timestamp: DateTime.parse('2026-03-14T12:00:00Z'),
        rawAdc: 15000,
        voltage: 2.5,
        deviceId: 'ADS1115_Pi',
      );

      final json = data.toJson();

      expect(json['timestamp'], '2026-03-14T12:00:00.000Z');
      expect(json['raw_adc'], 15000);
      expect(json['voltage'], 2.5);
      expect(json['device_id'], 'ADS1115_Pi');
    });
  });
}
