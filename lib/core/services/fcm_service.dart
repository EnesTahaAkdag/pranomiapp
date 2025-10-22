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
  static const String _permissionRequestedKey = 'fcm_permission_requested';

  // Callbacks for handling messages
  Function(RemoteMessage)? onForegroundMessage;
  Function(RemoteMessage)? onNotificationTap;

  /// Initialize FCM and request permissions (only once)
  /// Returns the authorization status after initialization
  Future<AuthorizationStatus> initialize() async {
    try {
      // Check if permission was already requested
      final prefs = await SharedPreferences.getInstance();
      final permissionRequested = prefs.getBool(_permissionRequestedKey) ?? false;

      NotificationSettings settings;

      if (!permissionRequested) {
        // First time - request permission
        debugPrint('📋 Requesting FCM permission for the first time...');
        settings = await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        // Mark permission as requested
        await prefs.setBool(_permissionRequestedKey, true);
        debugPrint('FCM Permission status: ${settings.authorizationStatus}');
      } else {
        // Permission already requested - just get current settings
        debugPrint('📋 FCM permission already requested, checking current settings...');
        settings = await _firebaseMessaging.getNotificationSettings();
        debugPrint('Current permission status: ${settings.authorizationStatus}');
      }

      // Get and save FCM token if permissions are granted
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final token = await getFCMToken();
        if (token != null) {
          await _saveFCMToken(token);
          debugPrint('FCM Token: $token');
        }
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM Token refreshed: $newToken');
        _saveFCMToken(newToken);
        // TODO: Send new token to backend when ready
      });

      // Setup message handlers
      _setupMessageHandlers();

      return settings.authorizationStatus;
    } catch (e) {
      debugPrint('Error initializing FCM: $e');
      return AuthorizationStatus.notDetermined;
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

  /// Reset permission requested flag (for testing purposes)
  /// This will allow the permission dialog to be shown again on next app start
  Future<void> resetPermissionRequestedFlag() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_permissionRequestedKey);
      debugPrint('Permission requested flag reset');
    } catch (e) {
      debugPrint('Error resetting permission flag: $e');
    }
  }
}
