import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_leafcloud_app/models/ph_sensor_data.dart';
import 'dart:convert';
import 'dart:async';

typedef WebSocketChannelFactory = WebSocketChannel Function(Uri url);

class PHMonitorNotifier extends ChangeNotifier {
  final List<PHSensorData> _readings = [];
  bool _isConnected = false;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final WebSocketChannelFactory _channelFactory;

  PHMonitorNotifier({
    WebSocketChannelFactory? channelFactory,
  }) : _channelFactory = channelFactory ?? ((url) => WebSocketChannel.connect(url));

  List<PHSensorData> get readings => List.unmodifiable(_readings);
  bool get isConnected => _isConnected;

  void connect(String url) {
    if (_isConnected) return;

    try {
      final uri = Uri.parse(url);
      _channel = _channelFactory(uri);
      _isConnected = true;
      notifyListeners();

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          _handleDisconnect();
        },
        onError: (error) {
          _handleDisconnect();
        },
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message as String) as Map<String, dynamic>;
      final String deviceId = data['device_id'] as String;
      final List<dynamic> readingsJson = data['readings'] as List<dynamic>;

      for (final reading in readingsJson) {
        final Map<String, dynamic> readingMap = Map<String, dynamic>.from(reading as Map);
        readingMap['device_id'] = deviceId;
        _readings.insert(0, PHSensorData.fromJson(readingMap));
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing pH message: $e');
    }
  }

  void _handleDisconnect() {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    notifyListeners();
  }

  void disconnect() {
    _handleDisconnect();
  }

  @override
  void dispose() {
    _handleDisconnect();
    super.dispose();
  }
}
