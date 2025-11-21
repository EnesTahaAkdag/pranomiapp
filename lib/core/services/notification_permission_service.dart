import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection.dart';

/// Service for managing notification permission state and preferences
/// Handles first-time permission request and user preference persistence
class NotificationPermissionService {
  // SharedPreferences keys
  static const String _keyPermissionAsked = 'notification_permission_asked';
  static const String _keyPermissionGranted = 'notification_permission_granted';
  static const String _keyDenialMessageShown = 'notification_denial_message_shown';

  /// Checks if notification permission has been asked before
  static Future<bool> hasAskedForPermission() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getBool(_keyPermissionAsked) ?? false;
  }

  /// Checks if notification permission was granted by user
  static Future<bool> isPermissionGranted() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getBool(_keyPermissionGranted) ?? false;
  }

  /// Request notification permission from user
  /// Returns true if granted, false if denied
  static Future<bool> requestPermission() async {
    try {
      debugPrint('🔔 Requesting notification permission...');

      // Request permission and get the result
      final granted = await OneSignal.Notifications.requestPermission(true);

      // Mark that we've asked for permission
      final prefs = locator<SharedPreferences>();
      await prefs.setBool(_keyPermissionAsked, true);
      await prefs.setBool(_keyPermissionGranted, granted);

      if (granted) {
        debugPrint('✅ Notification permission GRANTED');
      } else {
        debugPrint('❌ Notification permission DENIED');
      }

      return granted;
    } catch (e) {
      debugPrint('❌ Error requesting notification permission: $e');

      // If there's an error, mark as asked but not granted
      final prefs = locator<SharedPreferences>();
      await prefs.setBool(_keyPermissionAsked, true);
      await prefs.setBool(_keyPermissionGranted, false);

      return false;
    }
  }

  /// Reset permission state (for testing purposes)
  static Future<void> resetPermissionState() async {
    final prefs = locator<SharedPreferences>();
    await prefs.remove(_keyPermissionAsked);
    await prefs.remove(_keyPermissionGranted);
    await prefs.remove(_keyDenialMessageShown);
    debugPrint('🔄 Notification permission state reset');
  }

  /// Check if we should show permission request
  /// Returns true if we haven't asked before
  static Future<bool> shouldRequestPermission() async {
    return !(await hasAskedForPermission());
  }

  /// Check if denial message has been shown before
  static Future<bool> hasDenialMessageBeenShown() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getBool(_keyDenialMessageShown) ?? false;
  }

  /// Mark that denial message has been shown to user
  static Future<void> markDenialMessageShown() async {
    final prefs = locator<SharedPreferences>();
    await prefs.setBool(_keyDenialMessageShown, true);
    debugPrint('📝 Marked notification denial message as shown');
  }

  /// Check if we should show the denial message
  /// Returns true only if: permission denied AND message not shown before
  static Future<bool> shouldShowDenialMessage() async {
    final hasAsked = await hasAskedForPermission();
    final isGranted = await isPermissionGranted();
    final messageShown = await hasDenialMessageBeenShown();

    // Show message only if: asked before, denied, and message not shown yet
    return hasAsked && !isGranted && !messageShown;
  }
}
