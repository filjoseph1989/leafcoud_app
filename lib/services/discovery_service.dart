import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:nsd/nsd.dart' as nsd;
import 'package:leaf_cloud/core/constants.dart';

class DiscoveryService {
  static final DiscoveryService _instance = DiscoveryService._internal();
  factory DiscoveryService() => _instance;
  DiscoveryService._internal();

  static const String _fallbackUrl = 'http://192.168.1.20:8000';
  static const Duration _discoveryTimeout = Duration(seconds: 15);

  nsd.Discovery? _discovery;
  bool _isSearching = false;
  Timer? _timeoutTimer;

  /// Starts searching for the LeafCloud server on the local network.
  /// Falls back to [_fallbackUrl] after [_discoveryTimeout] if not found.
  Future<void> initDiscovery({String serviceType = '_leafcloud._tcp'}) async {
    if (_isSearching) return;
    _isSearching = true;

    debugPrint('Starting network discovery for $serviceType...');

    _timeoutTimer = Timer(_discoveryTimeout, () {
      if (ApiConstants.connectionNotifier.value == null) {
        debugPrint('Discovery timed out — falling back to $_fallbackUrl');
        ApiConstants.updateBaseUrl(_fallbackUrl);
        stopDiscovery();
      }
    });

    try {
      _discovery = await nsd.startDiscovery(serviceType);

      _discovery!.addListener(() {
        final services = _discovery!.services;
        if (services.isNotEmpty) {
          for (final service in services) {
            final port = service.port;

            String? hostAddress;
            if (service.addresses != null && service.addresses!.isNotEmpty) {
              hostAddress = service.addresses!.first.address;
            } else {
              hostAddress = service.host;
            }

            if (hostAddress != null && port != null) {
              if (hostAddress.endsWith('.')) {
                hostAddress = hostAddress.substring(0, hostAddress.length - 1);
              }

              final discoveredUrl = 'http://$hostAddress:$port';
              ApiConstants.updateBaseUrl(discoveredUrl);
              debugPrint('Discovered server at: $discoveredUrl');

              _timeoutTimer?.cancel();
              stopDiscovery();
              break;
            }
          }
        }
      });
    } catch (e) {
      debugPrint('Error during discovery: $e');
      _timeoutTimer?.cancel();
      ApiConstants.updateBaseUrl(_fallbackUrl);
      _isSearching = false;
    }
  }

  Future<void> stopDiscovery() async {
    _timeoutTimer?.cancel();
    if (_discovery != null) {
      await nsd.stopDiscovery(_discovery!);
      _discovery = null;
      _isSearching = false;
      debugPrint('Stopping network discovery.');
    }
  }
}
