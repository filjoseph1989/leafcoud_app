import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_leafcloud_app/models/ph_sensor_data.dart';
import 'dart:convert';
import 'dart:async';

typedef WebSocketChannelFactory = WebSocketChannel Function(Uri url);

class PHMonitorNotifier extends ChangeNotifier {
  final List<PHSensorData> _readings = [];
  bool _isConnected = false;
  bool _isReconnecting = false;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  final WebSocketChannelFactory _channelFactory;
  Timer? _reconnectTimer;

  PHMonitorNotifier({
    WebSocketChannelFactory? channelFactory,
  }) : _channelFactory = channelFactory ?? ((url) => WebSocketChannel.connect(url));

  List<PHSensorData> get readings => List.unmodifiable(_readings);
  bool get isConnected => _isConnected;
  bool get isReconnecting => _isReconnecting;

  void connect(String url) {
    if (_isConnected) return;
    _isReconnecting = true;
    notifyListeners();

    _establishConnection(url);
  }

  void _establishConnection(String url) {
    try {
      final uri = Uri.parse(url);
      _channel = _channelFactory(uri);
      
      _subscription = _channel!.stream.listen(
        (message) {
          if (!_isConnected) {
            _isConnected = true;
            _isReconnecting = false;
          }
          _handleMessage(message);
        },
        onDone: () {
          _handleDisconnect(url);
        },
        onError: (error) {
          _handleDisconnect(url);
        },
      );
    } catch (e) {
      _handleDisconnect(url);
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

  void _handleDisconnect(String url) {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    
    if (_isReconnecting) {
      // Retry connection after a delay
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () => _establishConnection(url));
    }
    
    notifyListeners();
  }

  void disconnect() {
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _handleDisconnect('');
  }

  @override
  void dispose() {
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _handleDisconnect('');
    super.dispose();
  }
}
