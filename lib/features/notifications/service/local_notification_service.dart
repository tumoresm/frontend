import 'dart:convert';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/notifications/model/notification_model.dart';
import 'package:fieldforce/features/notifications/model/notification_enums.dart';

/// Service for handling local notifications
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  Function(String)? _onNotificationTapped;

  /// Initialize the local notification service
  Future<void> initialize({
    Function(String)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;

    try {
      _onNotificationTapped = onNotificationTapped;

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      // Request permissions for iOS
      if (Platform.isIOS) {
        await _requestIOSPermissions();
      }

      // Request permissions for Android 13+
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      }

      _isInitialized = true;
      Loggers.database
          .info('Local notification service initialized successfully');
    } catch (e) {
      Loggers.database
          .error('Failed to initialize local notification service: $e');
      rethrow;
    }
  }

  /// Handle notification response (when user taps on notification)
  void _onNotificationResponse(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null && _onNotificationTapped != null) {
        _onNotificationTapped!(payload);
      }
      Loggers.database.info('Notification tapped with payload: $payload');
    } catch (e) {
      Loggers.database.warning('Error handling notification response: $e');
    }
  }

  /// Request iOS permissions
  Future<void> _requestIOSPermissions() async {
    try {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      Loggers.database.warning('Failed to request iOS permissions: $e');
    }
  }

  /// Request Android permissions
  Future<void> _requestAndroidPermissions() async {
    try {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    } catch (e) {
      Loggers.database.warning('Failed to request Android permissions: $e');
    }
  }

  /// Show a local notification
  Future<void> showNotification(NotificationModel notification) async {
    if (!_isInitialized) {
      Loggers.database.warning('Local notification service not initialized');
      return;
    }

    try {
      final androidDetails = _getAndroidNotificationDetails(notification);
      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _flutterLocalNotificationsPlugin.show(
        notification.id.hashCode, // Use hash code as integer ID
        notification.title,
        notification.body,
        notificationDetails,
        payload: jsonEncode({
          'id': notification.id,
          'category': notification.category.value,
          'actionUrl': notification.actionUrl,
          'actionType': notification.actionType,
        }),
      );

      Loggers.database.info('Local notification shown: ${notification.id}');
    } catch (e) {
      Loggers.database.error('Failed to show local notification: $e');
    }
  }

  /// Get Android notification details based on notification category and priority
  AndroidNotificationDetails _getAndroidNotificationDetails(
      NotificationModel notification) {
    final channelId = _getChannelId(notification.category);
    final channelName = _getChannelName(notification.category);
    final importance = _getImportance(notification.priority);
    final priority = _getPriority(notification.priority);

    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: notification.category.description,
      importance: importance,
      priority: priority,
      showWhen: true,
      when: notification.createdAt.millisecondsSinceEpoch,
      enableVibration: notification.isHighPriority,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: notification.imageUrl != null
          ? FilePathAndroidBitmap(notification.imageUrl!)
          : null,
      styleInformation: notification.body.length > 50
          ? BigTextStyleInformation(
              notification.body,
              contentTitle: notification.title,
            )
          : null,
    );
  }

  /// Get channel ID based on notification category
  String _getChannelId(NotificationCategory category) {
    switch (category) {
      case NotificationCategory.orderUpdate:
        return 'order_updates';
      case NotificationCategory.payment:
        return 'payments';
      case NotificationCategory.verification:
        return 'verification';
      case NotificationCategory.promotion:
        return 'promotions';
      case NotificationCategory.company:
        return 'companies';
      case NotificationCategory.system:
        return 'system';
      case NotificationCategory.security:
        return 'security';
    }
  }

  /// Get channel name based on notification category
  String _getChannelName(NotificationCategory category) {
    return category.displayName;
  }

  /// Get importance based on notification priority
  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.urgent:
        return Importance.max;
    }
  }

  /// Get priority based on notification priority
  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.urgent:
        return Priority.max;
    }
  }

  /// Schedule a notification for later
  Future<void> scheduleNotification(
    NotificationModel notification,
    DateTime scheduledDate,
  ) async {
    if (!_isInitialized) {
      Loggers.database.warning('Local notification service not initialized');
      return;
    }

    try {
      final androidDetails = _getAndroidNotificationDetails(notification);
      const iOSDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        notification.id.hashCode,
        notification.title,
        notification.body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        payload: jsonEncode({
          'id': notification.id,
          'category': notification.category.value,
          'actionUrl': notification.actionUrl,
          'actionType': notification.actionType,
        }),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      Loggers.database.info(
          'Notification scheduled for ${scheduledDate.toIso8601String()}');
    } catch (e) {
      Loggers.database.error('Failed to schedule notification: $e');
    }
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(String notificationId) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(notificationId.hashCode);
      Loggers.database.info('Cancelled notification: $notificationId');
    } catch (e) {
      Loggers.database.warning('Failed to cancel notification: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      Loggers.database.info('Cancelled all notifications');
    } catch (e) {
      Loggers.database.warning('Failed to cancel all notifications: $e');
    }
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _flutterLocalNotificationsPlugin
          .pendingNotificationRequests();
    } catch (e) {
      Loggers.database.warning('Failed to get pending notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      if (Platform.isAndroid) {
        final androidImplementation = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        return await androidImplementation?.areNotificationsEnabled() ?? false;
      } else if (Platform.isIOS) {
        final iOSImplementation = _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        return await iOSImplementation?.requestPermissions() ?? false;
      }
      return false;
    } catch (e) {
      Loggers.database.warning('Failed to check notification permissions: $e');
      return false;
    }
  }

  /// Create notification channels (Android only)
  Future<void> createNotificationChannels() async {
    if (!Platform.isAndroid) return;

    try {
      final androidImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation == null) return;

      // Create channels for each category
      for (final category in NotificationCategory.values) {
        final channelId = _getChannelId(category);
        final channelName = _getChannelName(category);

        await androidImplementation.createNotificationChannel(
          AndroidNotificationChannel(
            channelId,
            channelName,
            description: category.description,
            importance: Importance.defaultImportance,
            enableVibration: true,
            playSound: true,
          ),
        );
      }

      Loggers.database.info('Created notification channels');
    } catch (e) {
      Loggers.database.warning('Failed to create notification channels: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _isInitialized = false;
    _onNotificationTapped = null;
  }
}
