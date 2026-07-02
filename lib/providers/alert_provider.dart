import 'dart:async';
import 'package:flutter/material.dart';
import 'package:leaf_cloud/models/alert_model.dart';
import 'package:leaf_cloud/repositories/iot_repository_interface.dart';
import 'package:leaf_cloud/services/notification_service.dart';
import 'package:leaf_cloud/providers/config_provider.dart';

class AlertProvider extends ChangeNotifier {
  final IIotRepository _repository;
  final NotificationService _notificationService = NotificationService();
  final ConfigProvider _configProvider;

  Timer? _pollingTimer;
  bool _isPolling = false;
  bool _isLoading = false;

  final Map<int, AlertStatus> _alerts = {};
  
  AlertProvider(this._repository, this._configProvider) {
    _configProvider.addListener(_onConfigChanged);
    _startPolling();
  }

  bool get isLoading => _isLoading;
  Map<int, AlertStatus> get alerts => _alerts;

  void _onConfigChanged() {
    _checkAllAlerts();
  }

  void _startPolling() {
    if (_isPolling) return;
    _isPolling = true;
    
    // Poll every 5 minutes as per documentation
    _pollingTimer = Timer.periodic(const Duration(minutes: 5), (_) => _checkAllAlerts());
    
    // Also check immediately on start
    _checkAllAlerts();
  }

  Future<void> refresh() => _checkAllAlerts();

  Future<void> _checkAllAlerts() async {
    if (_isLoading) return;
    
    _isLoading = true;
    notifyListeners();

    final configs = _configProvider.configs;
    if (configs.isEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    try {
      for (final config in configs) {
        if (config.id == null) continue;
        
        try {
          final status = await _repository.getAlertStatus(config.id!);
          _alerts[config.id!] = status;
          
          // Notify if alert is triggered
          if (status.hasAlert) {
            await _notificationService.showAlertNotification(
              id: config.id!,
              title: 'LeafCloud ${status.level}: ${config.tankName}',
              body: status.message ?? 'Top-up required',
            );
          }
        } catch (e) {
          debugPrint('Error polling alerts for tank ${config.id}: $e');
        }
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _configProvider.removeListener(_onConfigChanged);
    super.dispose();
  }
}
