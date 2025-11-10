import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage theme mode and persist user preference
class ThemeService extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeService(this._prefs) {
    _loadThemeMode();
  }

  /// Current theme mode
  ThemeMode get themeMode => _themeMode;

  /// Check if dark mode is currently active
  bool isDarkMode(BuildContext context) {
    if (_themeMode == ThemeMode.dark) return true;
    if (_themeMode == ThemeMode.light) return false;
    // System mode - check device brightness
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  /// Load saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    final savedMode = _prefs.getString(_themeModeKey);
    if (savedMode != null) {
      _themeMode = _themeModeFromString(savedMode);
      notifyListeners();
    }
  }

  /// Set theme mode and persist it
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeModeKey, _themeModeToString(mode));
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else {
      await setThemeMode(ThemeMode.light);
    }
  }

  /// Convert ThemeMode to string for storage
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Convert string to ThemeMode
  ThemeMode _themeModeFromString(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }
}
