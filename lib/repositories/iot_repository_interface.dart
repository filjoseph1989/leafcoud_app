import 'package:leaf_cloud/models/dashboard_model.dart';
import 'package:leaf_cloud/models/history_model.dart';
import 'package:leaf_cloud/models/alert_model.dart';
import 'package:leaf_cloud/models/telemetry_model.dart';

abstract class IIotRepository {
  Future<DashboardData> getDashboard(int tankId);
  Future<HistoryData> getHistory(int tankId, {int days = 7, int limit = 200});
  Future<AlertStatus> getAlertStatus(int tankId);
  Future<LiveTelemetryData> getLiveTelemetry(int tankId);
}

