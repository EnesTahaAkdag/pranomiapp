import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Local Notification Service
/// Handles displaying notifications when app is in foreground
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback for notification taps
  Function(String?)? onNotificationTap;

  /// Initialize local notifications
  Future<void> initialize() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize and handle notification taps
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Local notification tapped: ${response.payload}');
        onNotificationTap?.call(response.payload);
      },
    );

    debugPrint('Local notifications initialized');
  }

  /// Create notification channel for Android
  Future<void> createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'pranomi_notifications', // id
      'Pranomi Notifications', // name
      description: 'Pranomi business notifications', // description
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    debugPrint('Android notification channel created');
  }

  /// Display notification from Firebase message
  Future<void> showNotificationFromFirebase(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification == null) {
      debugPrint('No notification data in message');
      return;
    }

    // Create notification details
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pranomi_notifications',
      'Pranomi Notifications',
      channelDescription: 'Pranomi business notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
      largeIcon: android?.imageUrl != null
          ? const DrawableResourceAndroidBitmap('@mipmap/ic_launcher')
          : null,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Show notification
    await _localNotifications.show(
      message.hashCode, // Use message hash as notification ID
      notification.title ?? 'Pranomi',
      notification.body ?? '',
      details,
      payload: _createPayload(message.data),
    );

    debugPrint('Local notification shown: ${notification.title}');
  }

  /// Display custom notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'pranomi_notifications',
      'Pranomi Notifications',
      channelDescription: 'Pranomi business notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Create payload string from notification data
  String _createPayload(Map<String, dynamic> data) {
    // Convert data map to payload string
    // You can customize this based on your needs
    final buffer = StringBuffer();
    data.forEach((key, value) {
      buffer.write('$key=$value&');
    });
    return buffer.toString();
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

  /// Get active notifications
  Future<List<ActiveNotification>> getActiveNotifications() async {
    final activeNotifications = await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.getActiveNotifications();
    return activeNotifications ?? [];
  }
}
