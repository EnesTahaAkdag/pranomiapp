import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection.dart';

class AuthService {
  static const String _apiKeyKey = 'apiKey';
  static const String _apiSecretKey = 'apiSecret';
  static const String _subscriptionTypeKey = 'subscriptionType';
  static const String _isEInvoiceActiveKey = 'isEInvoiceActive';

  /// Check if user is logged in by verifying if API credentials exist
  static Future<bool> isLoggedIn() async {
    final prefs = locator<SharedPreferences>();
    final apiKey = prefs.getString(_apiKeyKey);
    final apiSecret = prefs.getString(_apiSecretKey);
    return apiKey != null && apiSecret != null;
  }

  /// Logout user by clearing all authentication data
  static Future<void> logout() async {
    final prefs = locator<SharedPreferences>();
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_apiSecretKey);
    await prefs.remove(_subscriptionTypeKey);
    await prefs.remove(_isEInvoiceActiveKey);
  }

  /// Get API key
  static Future<String?> getApiKey() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getString(_apiKeyKey);
  }

  /// Get API secret
  static Future<String?> getApiSecret() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getString(_apiSecretKey);
  }

  /// Save authentication credentials
  static Future<void> saveCredentials({
    required String apiKey,
    required String apiSecret,
    String? subscriptionType,
    bool? isEInvoiceActive,
  }) async {
    final prefs = locator<SharedPreferences>();
    await prefs.setString(_apiKeyKey, apiKey);
    await prefs.setString(_apiSecretKey, apiSecret);

    if (subscriptionType != null) {
      await prefs.setString(_subscriptionTypeKey, subscriptionType);
    }

    if (isEInvoiceActive != null) {
      await prefs.setBool(_isEInvoiceActiveKey, isEInvoiceActive);
    }
  }

  /// Get subscription type
  static Future<String?> getSubscriptionType() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getString(_subscriptionTypeKey);
  }

  /// Check if E-Invoice is active
  static Future<bool> isEInvoiceActive() async {
    final prefs = locator<SharedPreferences>();
    return prefs.getBool(_isEInvoiceActiveKey) ?? false;
  }
}