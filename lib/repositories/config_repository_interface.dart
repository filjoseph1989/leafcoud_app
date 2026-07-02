import 'package:leaf_cloud/models/system_config_model.dart';

abstract class IConfigRepository {
  Future<List<SystemConfig>> listConfigs();
  Future<SystemConfig> getConfig(int id);
  Future<SystemConfig> createConfig(SystemConfig config);
  Future<SystemConfig> updateConfig(int id, SystemConfig config);
  Future<void> deleteConfig(int id);
}
