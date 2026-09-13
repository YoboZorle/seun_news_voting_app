import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

final logger = Logger();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  // Track if permissions have been requested
  static bool _permissionsRequested = false;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android initialization - use 'app_icon' (the default mipmap)
    const AndroidInitializationSettings androidInitializationSettings =
    AndroidInitializationSettings('app_icon');

    // iOS initialization with forced permission request
    const DarwinInitializationSettings iosInitializationSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: false,
    );

    final InitializationSettings initializationSettings =
    InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        logger.i('✅ Notification clicked: ${response.payload}');
      },
    );

    // Request iOS notification permissions (critical!)
    final iOSPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iOSPlugin != null) {
      final granted = await iOSPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        provisional: false, // Force user decision, not provisional
      );

      if (granted == true) {
        logger.i('✅ iOS notifications ALLOWED');
      } else {
        logger.w('⚠️ iOS notifications DENIED');
      }
    }

    // Request Android notification permissions (Android 13+)
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      if (granted == true) {
        logger.i('✅ Android notifications ALLOWED');
      } else {
        logger.w('⚠️ Android notifications DENIED');
      }
    }

    // Create notification channels for Android 8+
    await _createNotificationChannels();

    _permissionsRequested = true;
    logger.i('✅ NotificationService initialized with permissions');
  }

  /// Create notification channels for Android 8+
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Default channel
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'default_channel_id',
          'Default Notifications',
          description: 'General notifications',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );

      // Breaking news channel
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'breaking_news_id',
          'Breaking News',
          description: 'Breaking news alerts',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );

      // Milestone channel
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'milestone_id',
          'Milestones',
          description: 'Milestone notifications',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
        ),
      );

      logger.i('✅ Notification channels created');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    if (!_permissionsRequested) {
      logger.w('⚠️ Permissions not requested yet. Call init() first.');
      return;
    }

    try {
      final actualChannelId = channelId ?? 'default_channel_id';

      // Android notification details
      final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        actualChannelId,
        'Notifications',
        channelDescription: 'Important notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
        ongoing: false,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final NotificationDetails notificationDetails =
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      logger.i('✅ Notification shown: $title');
    } catch (e) {
      logger.e('❌ Error showing notification: $e');
    }
  }

  /// Show a critical/urgent notification
  Future<void> showCriticalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'breaking_news_id',
        'Breaking News',
        channelDescription: 'Breaking news alerts',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
      );

      const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final NotificationDetails notificationDetails =
      NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        notificationDetails,
        payload: payload,
      );

      logger.i('✅ Critical notification shown: $title');
    } catch (e) {
      logger.e('❌ Error showing critical notification: $e');
    }
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    logger.i('✅ All notifications cancelled');
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}