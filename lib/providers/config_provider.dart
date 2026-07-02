import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/system_config_model.dart';
import 'package:leaf_cloud/repositories/config_repository_interface.dart';

class ConfigProvider extends ChangeNotifier {
  final IConfigRepository _configRepository;

  ConfigProvider(this._configRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<SystemConfig> _configs = [];
  List<SystemConfig> get configs => _configs;

  SystemConfig? get activeConfig {
    try {
      return _configs.firstWhere((config) => config.isActive);
    } catch (_) {
      return _configs.isNotEmpty ? _configs.first : null;
    }
  }

  Future<void> fetchConfigs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _configs = await _configRepository.listConfigs();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createConfig(SystemConfig config) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newConfig = await _configRepository.createConfig(config);
      _configs.add(newConfig);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateConfig(int id, SystemConfig config) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _configRepository.updateConfig(id, config);
      final index = _configs.indexWhere((c) => c.id == id);
      if (index != -1) {
        _configs[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteConfig(int id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _configRepository.deleteConfig(id);
      _configs.removeWhere((c) => c.id == id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
