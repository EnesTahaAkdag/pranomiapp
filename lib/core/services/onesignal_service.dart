import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// Service for managing OneSignal user identification
/// This service handles login/logout operations to associate push notifications
/// with specific users using external_id
class OneSignalService {
  /// Login to OneSignal with user ID
  /// This sets the external_id which allows targeting specific users
  /// with push notifications from your backend
  ///
  /// [userId] - The user's ID from your backend system
  static Future<void> login(int userId) async {
    try {
      // Convert userId to string as OneSignal expects string external_id
      final externalId = userId.toString();

      debugPrint('🔐 OneSignal: Logging in with external_id: $externalId');

      // Set the external user ID
      await OneSignal.login(externalId);

      debugPrint('✅ OneSignal: Successfully logged in with external_id: $externalId');
    } catch (e) {
      debugPrint('❌ OneSignal: Login failed - ${e.toString()}');
    }
  }

  /// Logout from OneSignal
  /// This removes the external_id association
  /// Call this when user logs out from your app
  static Future<void> logout() async {
    try {
      debugPrint('🚪 OneSignal: Logging out...');

      // Logout from OneSignal
      await OneSignal.logout();

      debugPrint('✅ OneSignal: Successfully logged out');
    } catch (e) {
      debugPrint('❌ OneSignal: Logout failed - ${e.toString()}');
    }
  }
}
