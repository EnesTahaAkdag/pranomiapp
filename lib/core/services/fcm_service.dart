import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background message handler
/// Must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
}

/// Firebase Cloud Messaging Service
/// Handles FCM token management, message reception, and topic subscriptions
class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const String _fcmTokenKey = 'fcm_token';

  // Callbacks for handling messages
  Function(RemoteMessage)? onForegroundMessage;
  Function(RemoteMessage)? onNotificationTap;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM Permission granted: ${settings.authorizationStatus}');

      // Get and save FCM token
      final token = await getFCMToken();
      if (token != null) {
        await _saveFCMToken(token);
        debugPrint('FCM Token: $token');
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _saveFCMToken(newToken);
        // TODO: Send new token to backend when ready
      });

      // Setup message handlers
      _setupMessageHandlers();
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');
      debugPrint('Data: ${message.data}');

      // Call callback if set
      onForegroundMessage?.call(message);
    });

    // Handle notification taps (app opened from background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Notification tapped - app opened from background');
      debugPrint('Data: ${message.data}');

      // Call callback if set
      onNotificationTap?.call(message);
    });

    // Handle initial message (app opened from terminated state)
    _handleInitialMessage();
  }

  /// Handle initial message when app is opened from terminated state
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      debugPrint('Data: ${initialMessage.data}');

      // Call callback if set
      onNotificationTap?.call(initialMessage);
    }
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// Get saved FCM token from SharedPreferences
  Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fcmTokenKey);
    } catch (e) {
      debugPrint('Error getting saved FCM token: $e');
      return null;
    }
  }

  /// Save FCM token to SharedPreferences
  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
    } catch (e) {
      debugPrint('Error saving FCM token: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fcmTokenKey);
      debugPrint('FCM token deleted');
    } catch (e) {
      debugPrint('Error deleting FCM token: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _firebaseMessaging.getNotificationSettings();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
           settings.authorizationStatus == AuthorizationStatus.provisional;
  }
}
