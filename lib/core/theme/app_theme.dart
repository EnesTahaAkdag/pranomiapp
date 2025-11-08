
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

  /// Card background light (used for cards with subtle color)
  static const Color cardBackgroundLight = Color(0xFFe8ecf1);

  /// Scaffold background light (slightly different from standard)
  static const Color scaffoldBackgroundLight = Color(0xFFF5F7FA);

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

  /// Dark text color (primary dark text)
  static const Color textDark = Color(0xFF212121);

  /// Medium text color (secondary dark text)
  static const Color textMedium = Color(0xFF424141);

  /// Medium text color variant
  static const Color textMedium2 = Color(0xFF424242);

  // ============================================================================
  // ICON COLORS
  // ============================================================================

  /// Gray icon color (for secondary icons)
  static const Color iconGray = Color(0xFFA89494);

  /// Search icon color (blue)
  static const Color searchIconColor = Color(0xFF1976D2);

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
  // FINANCIAL/AMOUNT COLORS
  // ============================================================================

  /// Positive amount color (green for profits/credits)
  static const Color positiveAmountColor = Color(0xFF4CAF50);

  /// Negative amount color (red for debts/losses)
  static const Color negativeAmountColor = Color(0xFFE53935);

  /// Neutral amount color (gray for zero balances)
  static const Color neutralAmountColor = Color(0xFF2A2A2A);

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

  /// Gray shade 500
  static const Color gray500 = Color(0xFF9E9E9E);

  /// Gray shade 600
  static const Color gray600 = Color(0xFF757575);

  /// Gray shade 700
  static const Color gray700 = Color(0xFF616161);

  /// Gray shade 800
  static const Color gray800 = Color(0xFF424242);

  /// Unselected icon/text color - Light gray (#D1D5DB)
  static const Color unselectedColor = Color(0xFFD1D5DB);

  /// Deep orange (used for SVG icon tints)
  static const Color deepOrange = Colors.deepOrange;

  /// Orange color for warnings and highlights
  static const Color orange = Colors.orange;

  /// Shadow color for cards and elevated elements
  static const Color shadowColor = Color(0x1F000000);  // Colors.black12

  /// Light shadow color (black12)
  static const Color shadowColorLight = Color(0x1F000000);  // Colors.black12

  /// Primary text color (black87)
  static const Color textPrimary = Color(0xDD000000);  // Colors.black87

  // ============================================================================
  // CREDIT/BALANCE SPECIFIC COLORS
  // ============================================================================

  /// Credit balance card background - Blue accent
  static const Color creditBalanceCardBackground = Color(0xFF448AFF); // Colors.blueAccent

  /// Credit page light background
  static const Color creditPageBackground = Color(0xFFFAFAFA); // Colors.grey[50]

  /// Transaction positive/income color - Green
  static const Color transactionIncomeColor = Color(0xFF4CAF50); // Colors.green

  /// Transaction negative/expense color - Red
  static const Color transactionExpenseColor = Color(0xFFF44336); // Colors.red

  /// Description container background - Light blue
  static const Color descriptionBackgroundLight = Color(0xFFE3F2FD); // Colors.blue with alpha 0.05

  /// Description border color - Blue
  static const Color descriptionBorderColor = Color(0xFFBBDEFB); // Colors.blue with alpha 0.1

  /// Description text/icon color - Dark blue
  static const Color descriptionTextColor = Color(0xFF0D47A1); // Colors.blue[900]

  /// Balance card overlay - Semi-transparent white
  static Color balanceCardOverlay = Colors.white.withValues(alpha: 0.2);

  /// Empty state icon background
  static const Color emptyStateIconBackground = Color(0xFFFAFAFA); // Colors.grey[100]

  /// Empty state icon color
  static const Color emptyStateIconColor = Color(0xFFBDBDBD); // Colors.grey[400]

  /// Empty state title color
  static const Color emptyStateTitleColor = Color(0xFF424242); // Colors.grey[800]

  /// Empty state subtitle color
  static const Color emptyStateSubtitleColor = Color(0xFF757575); // Colors.grey[600]

  /// Transaction card background
  static const Color transactionCardBackground = Colors.white;

  /// Transaction card shadow
  static Color transactionCardShadow = Colors.black.withValues(alpha: 0.04);

  /// Transaction badge background - Light gray
  static const Color transactionBadgeBackground = Color(0xFFFAFAFA); // Colors.grey[100]

  /// Transaction badge text color
  static const Color transactionBadgeTextColor = Color(0xFF616161); // Colors.grey[700]

  /// Transaction time container background
  static const Color transactionTimeBackground = Color(0xFFFAFAFA); // Colors.grey[50]

  /// Transaction time icon color
  static const Color transactionTimeIconColor = Color(0xFF757575); // Colors.grey[600]

  /// Transaction time text color
  static const Color transactionTimeTextColor = Color(0xFF616161); // Colors.grey[700]

  // ============================================================================
  // BUTTON AND UI ELEMENT COLORS
  // ============================================================================

  /// Button success/green color (for confirmations, success actions)
  static const Color buttonSuccessColor = Color(0xFF4CAF50); // Colors.green

  /// Button error/red color (for cancel, delete actions)
  static const Color buttonErrorColor = Color(0xFFF44336); // Colors.red

  /// Button warning/orange color (for warnings)
  static const Color buttonWarningColor = Color(0xFFFF9800); // Colors.orange

  /// Accent color for loading indicators
  static const Color loadingAccentColor = Color(0xFFFFD740); // Colors.amberAccent

  /// Blue color for icons and links
  static const Color blueAccent = Color(0xFF2196F3); // Colors.blue

  /// Blue shade 700 (darker blue)
  static const Color blue700 = Color(0xFF1976D2); // Colors.blue[700]

  // ============================================================================
  // NOTIFICATION TYPE COLORS
  // ============================================================================

  /// Notification type - Order new (green)
  static const Color notificationOrderNew = Color(0xFF4CAF50);

  /// Notification type - Invoice/Waybill add (light green)
  static const Color notificationInvoiceAdd = Color(0xFF66BB6A);

  /// Notification type - Stock change (blue)
  static const Color notificationStockChange = Color(0xFF2196F3);

  /// Notification type - Invoice/Waybill update (light blue)
  static const Color notificationInvoiceUpdate = Color(0xFF42A5F5);

  /// Notification type - Product out of stock (orange)
  static const Color notificationOutOfStock = Color(0xFFFF9800);

  /// Notification type - Claim new (light orange)
  static const Color notificationClaimNew = Color(0xFFFFB74D);

  /// Notification type - Invoice/Waybill cancelled (orange)
  static const Color notificationInvoiceCancelled = Color(0xFFFF9800);

  /// Notification type - E-Archive invoice cancel (coral orange)
  static const Color notificationEArchiveCancel = Color(0xFFFF8A65);

  /// Notification type - Order cancelled (red)
  static const Color notificationOrderCancelled = Color(0xFFF44336);

  /// Notification type - Invoice/Waybill delete (dark red)
  static const Color notificationInvoiceDelete = Color(0xFFE53935);

  /// Notification type - Invoice/Waybill error (darker red)
  static const Color notificationInvoiceError = Color(0xFFD32F2F);

  /// Notification type - E-Document error (darkest red)
  static const Color notificationEDocumentError = Color(0xFFC62828);

  /// Notification type - Transaction delete (grey)
  static const Color notificationTransactionDelete = Color(0xFF757575);

  /// Notification type - Default/Other (grey-blue)
  static const Color notificationDefault = Color(0xFF607D8B);

  /// Notification info chip - Date color (blue)
  static const Color notificationDateColor = Colors.blue;

  /// Notification info chip - Reference color (dark green)
  static const Color notificationReferenceColor = Color(0xFF164129);

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