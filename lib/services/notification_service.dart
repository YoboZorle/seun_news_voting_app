import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

final logger = Logger();

/// Callback for notification taps
typedef NotificationTapCallback = void Function(String payload);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  static bool _initialized = false;
  static NotificationTapCallback? _onNotificationTap;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize notification service with permission requests
  Future<void> init({NotificationTapCallback? onNotificationTap}) async {
    if (_initialized) {
      logger.i('✅ NotificationService already initialized');
      return;
    }

    _onNotificationTap = onNotificationTap;
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      requestCriticalPermission: true, // ← Critical alerts
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    // Request Android permissions (Android 13+)
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      logger.i(granted == true
          ? '✅ Android notifications ALLOWED'
          : '⚠️ Android notifications DENIED');
    }

    // Request iOS permissions
    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        critical: true,
      );
      logger.i(granted == true
          ? '✅ iOS notifications ALLOWED'
          : '⚠️ iOS notifications DENIED');
    }

    // Create notification channels for Android 8+
    await _createNotificationChannels();

    _initialized = true;
    logger.i('✅ NotificationService fully initialized');
  }

  /// Create notification channels for Android
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
          description: 'General notifications and updates',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('notification'),
        ),
      );

      // Critical alerts channel
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'critical_alerts_id',
          'Critical Alerts',
          description: 'Urgent milestones and breaking news',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          enableLights: true,
          sound: const RawResourceAndroidNotificationSound('notification'),
        ),
      );

      // Election updates channel
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          'election_updates_id',
          'Election Updates',
          description: 'Real-time election results',
          importance: Importance.high,
          enableVibration: true,
          playSound: true,
        ),
      );

      logger.i('✅ Notification channels created');
    }
  }

  /// Handle notification tap - route to content
  void _handleNotificationResponse(NotificationResponse response) {
    logger.i('📲 Notification tapped: ${response.payload}');

    if (response.payload != null && response.payload!.isNotEmpty) {
      _onNotificationTap?.call(response.payload!);
    }
  }

  /// Show regular notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    if (!_initialized) {
      logger.w('⚠️ NotificationService not initialized');
      return;
    }

    try {
      final channel = channelId ?? 'default_channel_id';

      final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        channel,
        'Notifications',
        channelDescription: 'General notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        autoCancel: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload ?? '',
      );

      logger.i('✅ Notification sent: $title');
    } catch (e) {
      logger.e('❌ Error sending notification: $e');
    }
  }

  /// Show critical notification with Dynamic Island support
  Future<void> showCriticalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) {
      logger.w('⚠️ NotificationService not initialized');
      return;
    }

    try {
      final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'critical_alerts_id',
        'Critical Alerts',
        channelDescription: 'Urgent alerts',
        importance: Importance.max,
        priority: Priority.max,
        enableVibration: true,
        playSound: true,
        enableLights: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        badgeNumber: 1,
        sound: 'default',
        // Dynamic Island support (iOS 16+)
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload ?? '',
      );

      logger.i('🔴 CRITICAL notification sent: $title');
    } catch (e) {
      logger.e('❌ Error sending critical notification: $e');
    }
  }

  /// Show real-time update notification
  Future<void> showRealtimeUpdate({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_initialized) return;

    try {
      final AndroidNotificationDetails androidDetails =
      AndroidNotificationDetails(
        'election_updates_id',
        'Election Updates',
        channelDescription: 'Real-time updates',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: false, // No sound for frequent updates
        autoCancel: true,
        styleInformation: BigTextStyleInformation(body),
      );

      const DarwinNotificationDetails iosDetails =
      DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: false,
        badgeNumber: 1,
      );

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecond,
        title,
        body,
        details,
        payload: payload ?? '',
      );
    } catch (e) {
      logger.e('Error sending realtime update: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    logger.i('✅ All notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  /// Get notification status
  Future<bool> notificationsEnabled() async {
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      return (await androidPlugin.areNotificationsEnabled()) ?? false;
    }
    return true; // iOS assumes enabled if initialized
  }
}