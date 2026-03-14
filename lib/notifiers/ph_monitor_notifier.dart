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
  bool _isMonitoring = false;
  bool _isDisposed = false;
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
  bool get isMonitoring => _isMonitoring;

  @override
  void notifyListeners() {
    if (!_isDisposed) {
      super.notifyListeners();
    }
  }

  void connect(String url) {
    if (_isConnected || _isReconnecting) return;
    _isMonitoring = true;
    _isReconnecting = true;
    notifyListeners();

    _establishConnection(url);
  }

  Future<void> _establishConnection(String url) async {
    debugPrint('Connecting to pH WebSocket: $url');
    try {
      final uri = Uri.parse(url);
      _channel = _channelFactory(uri);
      
      // Wait for the connection to be ready
      await _channel!.ready;
      
      if (_isDisposed) {
        _channel!.sink.close();
        return;
      }

      _isConnected = true;
      _isReconnecting = false;
      debugPrint('Connected to pH WebSocket');
      notifyListeners();
      
      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onDone: () {
          debugPrint('pH WebSocket connection closed (done)');
          _handleDisconnect(url);
        },
        onError: (error) {
          debugPrint('pH WebSocket error: $error');
          _handleDisconnect(url);
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('pH WebSocket connection failed: $e');
      _handleDisconnect(url);
    }
  }

  void _handleMessage(dynamic message) {
    try {
      final Map<String, dynamic> data = jsonDecode(message as String) as Map<String, dynamic>;
      final String deviceId = data['device_id'] as String;
      final List<dynamic> readingsJson = data['readings'] as List<dynamic>;

      if (readingsJson.isNotEmpty) {
        for (final reading in readingsJson) {
          final Map<String, dynamic> readingMap = Map<String, dynamic>.from(reading as Map);
          readingMap['device_id'] = deviceId;
          _readings.insert(0, PHSensorData.fromJson(readingMap));
        }
        // Keep only last 100 readings to prevent memory issues
        if (_readings.length > 100) {
          _readings.removeRange(100, _readings.length);
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error parsing pH message: $e');
    }
  }

  void _handleDisconnect(String url) {
    _isConnected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    
    if (_isReconnecting && !_isDisposed && url.isNotEmpty) {
      debugPrint('Attempting to reconnect in 5 seconds...');
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 5), () => _establishConnection(url));
    }
    
    notifyListeners();
  }

  void disconnect() {
    _isMonitoring = false;
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _handleDisconnect('');
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isMonitoring = false;
    _isReconnecting = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _isConnected = false;
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }
}
