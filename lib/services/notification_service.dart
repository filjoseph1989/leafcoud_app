import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart' as fln;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final fln.FlutterLocalNotificationsPlugin _notificationsPlugin = fln.FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const fln.AndroidInitializationSettings androidSettings = fln.AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const fln.DarwinInitializationSettings darwinSettings = fln.DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const fln.InitializationSettings settings = fln.InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (fln.NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );
  }

  Future<void> showAlertNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const fln.AndroidNotificationDetails androidDetails = fln.AndroidNotificationDetails(
      'nutrient_alerts',
      'Nutrient Alerts',
      channelDescription: 'Notifications for low nutrient levels and top-up instructions',
      importance: fln.Importance.high,
      priority: fln.Priority.high,
      color: Color(0xFF4E7A43),
    );

    const fln.DarwinNotificationDetails darwinDetails = fln.DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const fln.NotificationDetails details = fln.NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}
