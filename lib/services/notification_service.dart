import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  static final logger = Logger();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  int _notificationId = 0;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    try {
      // Android Configuration
      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('ic_launcher');

      // iOS Configuration with DynamicIsland support (iOS 16+)
      // Note: onDidReceiveLocalNotification is not supported in v18.0.0+
      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize with on tap callback
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      );

      // Request permissions (iOS)
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        critical: true,
      );

      // Request permissions (Android 13+)
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      logger.i('✅ NotificationService initialized successfully');
    } catch (e) {
      logger.e('Error initializing notifications: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    bool isCritical = false,
  }) async {
    try {
      _notificationId++;

      // Android Notification Details
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
        'naijanews_channel',
        'NG News Updates',
        channelDescription: 'Real-time news, elections & voting updates',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        enableVibration: true,
        enableLights: true,
        color: Color.fromARGB(255, 13, 71, 161),
        colorized: true,
        fullScreenIntent: true,
        ticker: 'NG News',
      );

      // iOS Notification Details with DynamicIsland support
      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
        threadIdentifier: 'naijanews_thread',
        interruptionLevel: InterruptionLevel.timeSensitive,
        subtitle: 'Live Update',
      );

      final NotificationDetails platformChannelSpecifics =
      NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Show notification
      await flutterLocalNotificationsPlugin.show(
        _notificationId,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      logger.i('📬 Notification: $title');
    } catch (e) {
      logger.e('Error showing notification: $e');
    }
  }

  // Callback when notification is tapped (handles both foreground and background)
  static Future<void> onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse,
      ) async {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      logger.i('📲 Notification tapped: $payload');
      // Handle notification tap here (navigate to specific screen, etc.)
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await flutterLocalNotificationsPlugin.cancel(id);
    } catch (e) {
      logger.e('Error canceling notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await flutterLocalNotificationsPlugin.cancelAll();
    } catch (e) {
      logger.e('Error canceling all notifications: $e');
    }
  }
}
