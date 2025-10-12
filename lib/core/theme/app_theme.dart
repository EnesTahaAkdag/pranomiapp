
import 'package:flutter/material.dart';

/// Centralized theme configuration for the Pranomi app
/// This file contains all color definitions and theme data
class AppTheme {
  // ============================================================================
  // PRIMARY BRAND COLORS
  // ============================================================================

  /// Primary brand color - Dark Gray (#3D3D3D)
  static const Color primaryColor = Color(0xFF3D3D3D);

  /// Accent/Secondary brand color - Cranberry Red (#B00034)
  static const Color accentColor = Color(0xFFB00034);

  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================

  /// Light scaffold background color
  static const Color scaffoldBackgroundColor = Colors.white;

  /// Dark scaffold background color
  static const Color scaffoldBackgroundColorDark = Color(0xFF1E1E1E);

  /// Light gray background (used in lists, cards)
  static const Color lightGrayBackground = Color(0xFFF5F5F5);

  /// Medium gray background
  static const Color mediumGrayBackground = Color(0xFF2C2C2C);

  /// Dark gray background
  static const Color darkGrayBackground = Color(0xFF3F3F3F);

  /// AppBar dark background
  static const Color appBarDarkBackground = Color(0xFF1F2937);

  /// AppBar darker background (for dark theme)
  static const Color appBarDarkerBackground = Color(0xFF2D2D2D);

  // ============================================================================
  // TEXT COLORS
  // ============================================================================

  /// Primary white text color
  static const Color textWhite = Colors.white;

  /// Secondary white text color (70% opacity)
  static const Color textWhite70 = Colors.white70;

  /// Primary black text color (87% opacity)
  static const Color textBlack87 = Colors.black87;

  /// Secondary black text color (54% opacity)
  static const Color textBlack54 = Colors.black54;

  /// Gray text color (700 shade)
  static const Color textGray = Color(0xFF616161);

  /// Light gray text color (600 shade)
  static const Color textGrayLight = Color(0xFF757575);

  // ============================================================================
  // STATUS COLORS
  // ============================================================================

  /// Success/Asset color - Green
  static const Color successColor = Color(0xFF2E7D32);  // Colors.green.shade700

  /// Error/Liability color - Red
  static const Color errorColor = Color(0xFFC62828);  // Colors.red.shade700

  /// Warning color - Orange
  static const Color warningColor = Colors.orange;

  /// Info color - Blue
  static const Color infoColor = Colors.blue;

  /// Selected tab/button color - Blue (#3B82F6)
  static const Color selectedItemColor = Color(0xFF3B82F6);

  /// Error light background
  static const Color errorLightBackground = Color(0xFFFFCDD2);  // Colors.red.shade100

  /// Error dark text
  static const Color errorDarkText = Color(0xFFB71C1C);  // Colors.red.shade900

  // ============================================================================
  // NEUTRAL COLORS
  // ============================================================================

  /// Pure white
  static const Color white = Colors.white;

  /// Pure black
  static const Color black = Colors.black;

  /// Transparent
  static const Color transparent = Colors.transparent;

  /// Gray shade 100
  static const Color gray100 = Color(0xFFF5F5F5);

  /// Gray shade 200
  static const Color gray200 = Color(0xFFEEEEEE);

  /// Gray shade 600
  static const Color gray600 = Color(0xFF757575);

  /// Gray shade 700
  static const Color gray700 = Color(0xFF616161);

  /// Unselected icon/text color - Light gray (#D1D5DB)
  static const Color unselectedColor = Color(0xFFD1D5DB);

  /// Deep orange (used for SVG icon tints)
  static const Color deepOrange = Colors.deepOrange;

  // ============================================================================
  // OPACITY HELPERS
  // ============================================================================

  /// Semi-transparent black overlay (70% opacity)
  static Color blackOverlay70 = Colors.black.withValues(alpha: 0.7);

  /// Semi-transparent black overlay (60% opacity)
  static Color blackOverlay60 = Colors.black.withValues(alpha: 0.6);

  /// Semi-transparent black overlay (50% opacity)
  static Color blackOverlay50 = Colors.black.withValues(alpha: 0.5);

  /// Semi-transparent black overlay (30% opacity)
  static Color blackOverlay30 = Colors.black.withValues(alpha: 0.3);

  /// Semi-transparent black overlay (10% opacity)
  static Color blackOverlay10 = Colors.black.withValues(alpha: 0.1);

  /// Semi-transparent white overlay (10% opacity)
  static Color whiteOverlay10 = Colors.white.withValues(alpha: 0.1);

  // ============================================================================
  // STATUS BAR COLOR
  // ============================================================================

  /// Status bar color
  static const Color statusBarColor = Color(0xFF292929);  // Color.fromARGB(255, 41, 41, 41)

  // ============================================================================
  // THEME DATA
  // ============================================================================

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor,
        elevation: 0,
        foregroundColor: textWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textWhite,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: white,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onError: textWhite,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColorDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarDarkerBackground,
        elevation: 0,
        foregroundColor: textWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textWhite,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: accentColor,
        error: errorColor,
        surface: mediumGrayBackground,
        onPrimary: textWhite,
        onSecondary: textWhite,
        onError: textWhite,
      ),
    );
  }
}