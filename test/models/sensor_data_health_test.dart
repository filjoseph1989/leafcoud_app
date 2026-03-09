import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_leafcloud_app/models/sensor_data.dart';

void main() {
  group('SensorData Health Mapping', () {
    test('should resolve healthStatus from nested overall_status Map', () {
      final json = {
        'timestamp': '2026-03-01T14:30:00Z',
        'status': {
          'overall_status': 'Optimal',
          'experiment_id': 'EXP-123'
        },
      };

      final sensorData = SensorData.fromJson(json);

      // We'll add healthStatus to the model
      // This will fail initially because the model doesn't have healthStatus
      expect(sensorData.healthStatus, 'Optimal');
    });

    test('should resolve healthStatus from String status', () {
      final json = {
        'timestamp': '2026-03-01T14:30:00Z',
        'status': 'Optimal',
      };

      final sensorData = SensorData.fromJson(json);

      expect(sensorData.healthStatus, 'Optimal');
    });

    test('should return No Data Yet if status is missing or malformed', () {
      final json = {
        'timestamp': '2026-03-01T14:30:00Z',
        'status': null,
      };

      final sensorData = SensorData.fromJson(json);

      expect(sensorData.healthStatus, 'No Data Yet');
    });
  });
}
