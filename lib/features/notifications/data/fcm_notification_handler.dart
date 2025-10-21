import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/services/fcm_service.dart';
import 'package:pranomiapp/core/services/local_notification_service.dart';

/// Helper class to handle FCM notifications and integrate with existing notification system
class FcmNotificationHandler {
  static BuildContext? _context;

  /// Initialize FCM notification handlers
  static Future<void> initialize(BuildContext context) async {
    _context = context;

    final fcmService = locator<FcmService>();
    final localNotificationService = locator<LocalNotificationService>();

    // Handle notification taps (when app is in background or terminated)
    fcmService.onNotificationTap = (RemoteMessage message) {
      _handleNotificationTap(message);
    };

    // Handle foreground messages
    fcmService.onForegroundMessage = (RemoteMessage message) {
      _handleForegroundMessage(message, localNotificationService);
    };

    // Handle local notification taps
    localNotificationService.onNotificationTap = (String? payload) {
      _handleLocalNotificationTap(payload);
    };

    debugPrint('FCM Notification Handler initialized');
  }

  /// Handle notification tap navigation
  static void _handleNotificationTap(RemoteMessage message) {
    if (_context == null || !_context!.mounted) return;

    debugPrint('Notification tapped: ${message.data}');

    // Parse notification data
    final data = message.data;
    _navigateBasedOnData(data);
  }

  /// Handle local notification tap
  static void _handleLocalNotificationTap(String? payload) {
    if (_context == null || !_context!.mounted || payload == null) return;

    debugPrint('Local notification tapped: $payload');

    // Parse payload into data map
    final data = <String, dynamic>{};
    final pairs = payload.split('&');
    for (final pair in pairs) {
      if (pair.isEmpty) continue;
      final keyValue = pair.split('=');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }

    _navigateBasedOnData(data);
  }

  /// Navigate based on notification data
  static void _navigateBasedOnData(Map<String, dynamic> data) {
    if (_context == null || !_context!.mounted) return;

    final notificationType = data['notificationType'];
    final referenceNumber = data['referenceNumber'];

    debugPrint('Navigation data - Type: $notificationType, Ref: $referenceNumber');

    // Navigate based on notification type
    if (notificationType != null) {
      switch (notificationType.toString()) {
        case '1': // Invoice notification
          if (referenceNumber != null) {
            _context!.push('/invoice/detail/$referenceNumber');
          } else {
            _context!.push('/invoices');
          }
          break;

        case '2': // E-Invoice notification
          if (referenceNumber != null) {
            _context!.push('/e-invoice/detail/$referenceNumber');
          } else {
            _context!.push('/e-invoices');
          }
          break;

        case '3': // Customer notification
          if (referenceNumber != null) {
            _context!.push('/customer/detail/$referenceNumber');
          } else {
            _context!.push('/customers');
          }
          break;

        case '4': // Credit notification
          _context!.push('/credit');
          break;

        case '5': // Announcement notification
          _context!.push('/announcements');
          break;

        case '6': // Product notification
          if (referenceNumber != null) {
            _context!.push('/product/detail/$referenceNumber');
          } else {
            _context!.push('/products');
          }
          break;

        default:
          // Navigate to notifications page for unknown types
          _context!.push('/notifications');
          break;
      }
    } else {
      // Default: navigate to notifications page
      _context!.push('/notifications');
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(
    RemoteMessage message,
    LocalNotificationService localNotificationService,
  ) {
    debugPrint('Foreground message received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');

    // Show local notification when app is in foreground
    localNotificationService.showNotificationFromFirebase(message);
  }

  /// Send FCM token to backend (placeholder for future implementation)
  static Future<void> sendTokenToBackend() async {
    final fcmService = locator<FcmService>();
    final token = await fcmService.getFCMToken();

    if (token != null) {
      debugPrint('FCM Token ready to send: $token');

      // TODO: Implement API call to send token to Pranomi backend when ready
      // Example endpoint: https://apitest.pranomi.com/user/register-device
      // Payload: { "fcm_token": token, "platform": "android" or "ios" }

      debugPrint('Backend integration pending - token not sent yet');
    }
  }

  /// Remove FCM token from backend (call on logout)
  static Future<void> removeTokenFromBackend() async {
    final fcmService = locator<FcmService>();
    final token = await fcmService.getSavedFCMToken();

    if (token != null) {
      debugPrint('Removing FCM token from backend: $token');

      // TODO: Implement API call to remove token from Pranomi backend
      // Example endpoint: https://apitest.pranomi.com/user/unregister-device
      // Payload: { "fcm_token": token }

      // Delete local token
      await fcmService.deleteToken();
    }
  }

  /// Subscribe to user-specific topic (call after login)
  static Future<void> subscribeToUserTopic(String userId) async {
    final fcmService = locator<FcmService>();
    await fcmService.subscribeToTopic('user_$userId');
    debugPrint('Subscribed to user topic: user_$userId');
  }

  /// Unsubscribe from user-specific topic (call on logout)
  static Future<void> unsubscribeFromUserTopic(String userId) async {
    final fcmService = locator<FcmService>();
    await fcmService.unsubscribeFromTopic('user_$userId');
    debugPrint('Unsubscribed from user topic: user_$userId');
  }

  /// Get current FCM token (for testing/debugging)
  static Future<String?> getCurrentToken() async {
    final fcmService = locator<FcmService>();
    return await fcmService.getFCMToken();
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final fcmService = locator<FcmService>();
    return await fcmService.areNotificationsEnabled();
  }
}
