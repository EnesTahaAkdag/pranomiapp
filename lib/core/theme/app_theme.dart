
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
  // DARK THEME SPECIFIC COLORS
  // ============================================================================

  /// Dark theme - Card background (elevated surface)
  static const Color darkCardBackground = Color(0xFF2C2C2C);

  /// Dark theme - Elevated card background (slightly lighter)
  static const Color darkCardBackgroundElevated = Color(0xFF353535);

  /// Dark theme - Input field background
  static const Color darkInputBackground = Color(0xFF3A3A3A);

  /// Dark theme - Divider color
  static const Color darkDividerColor = Color(0xFF404040);

  /// Dark theme - Primary text color (high emphasis)
  static const Color darkTextPrimary = Color(0xFFE0E0E0);

  /// Dark theme - Secondary text color (medium emphasis)
  static const Color darkTextSecondary = Color(0xFFB0B0B0);

  /// Dark theme - Tertiary text color (low emphasis/disabled)
  static const Color darkTextTertiary = Color(0xFF808080);

  /// Dark theme - Icon color
  static const Color darkIconColor = Color(0xFFB0B0B0);

  /// Dark theme - Success color (brighter for dark background)
  static const Color darkSuccessColor = Color(0xFF66BB6A);

  /// Dark theme - Error color (brighter for dark background)
  static const Color darkErrorColor = Color(0xFFEF5350);

  /// Dark theme - Warning color (brighter for dark background)
  static const Color darkWarningColor = Color(0xFFFFB74D);

  /// Dark theme - Info color (brighter for dark background)
  static const Color darkInfoColor = Color(0xFF42A5F5);

  /// Dark theme - Credit page background
  static const Color darkCreditPageBackground = Color(0xFF1E1E1E);

  /// Dark theme - Credit balance card background
  static const Color darkCreditBalanceCardBackground = Color(0xFF1976D2);

  /// Dark theme - Transaction card background
  static const Color darkTransactionCardBackground = Color(0xFF2C2C2C);

  /// Dark theme - Transaction badge background
  static const Color darkTransactionBadgeBackground = Color(0xFF3A3A3A);

  /// Dark theme - Transaction time background
  static const Color darkTransactionTimeBackground = Color(0xFF353535);

  /// Dark theme - Description background
  static const Color darkDescriptionBackground = Color(0xFF1A237E);

  /// Dark theme - Description border
  static const Color darkDescriptionBorder = Color(0xFF283593);

  /// Dark theme - Empty state icon background
  static const Color darkEmptyStateIconBackground = Color(0xFF2C2C2C);

  /// Dark theme - Empty state icon color
  static const Color darkEmptyStateIconColor = Color(0xFF757575);

  /// Dark theme - Shadow color (lighter for visibility on dark backgrounds)
  static Color darkShadowColor = Colors.black.withValues(alpha: 0.3);

  /// Dark theme - Card shadow (more prominent)
  static Color darkCardShadow = Colors.black.withValues(alpha: 0.5);

  /// Dark theme - Balance card overlay
  static Color darkBalanceCardOverlay = Colors.black.withValues(alpha: 0.2);

  // ============================================================================
  // CONTEXT-AWARE COLOR GETTERS
  // ============================================================================

  /// Get appropriate background color based on theme brightness
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? scaffoldBackgroundColorDark
        : scaffoldBackgroundColor;
  }

  /// Get appropriate card background color based on theme brightness
  static Color getCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCardBackground
        : white;
  }

  /// Get appropriate text primary color based on theme brightness
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextPrimary
        : textPrimary;
  }

  /// Get appropriate text secondary color based on theme brightness
  static Color getTextSecondary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTextSecondary
        : textGray;
  }

  /// Get appropriate success color based on theme brightness
  static Color getSuccessColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkSuccessColor
        : successColor;
  }

  /// Get appropriate error color based on theme brightness
  static Color getErrorColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkErrorColor
        : errorColor;
  }

  /// Get appropriate warning color based on theme brightness
  static Color getWarningColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkWarningColor
        : warningColor;
  }

  /// Get appropriate shadow color based on theme brightness
  static Color getShadowColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkShadowColor
        : shadowColor;
  }

  /// Get appropriate credit page background based on theme brightness
  static Color getCreditPageBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkCreditPageBackground
        : creditPageBackground;
  }

  /// Get appropriate transaction card background based on theme brightness
  static Color getTransactionCardBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkTransactionCardBackground
        : transactionCardBackground;
  }

  // ============================================================================
  // THEME DATA
  // ============================================================================

  /// Light theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardBackgroundLight,
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
      cardColor: darkCardBackground,
      dividerColor: darkDividerColor,

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: appBarDarkerBackground,
        elevation: 0,
        foregroundColor: textWhite,
        iconTheme: IconThemeData(color: textWhite),
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: textWhite,
          elevation: 2,
        ),
      ),

      // Text button theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkInfoColor,
        ),
      ),

      // Outlined button theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkTextPrimary,
          side: const BorderSide(color: darkDividerColor),
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 2,
        shadowColor: darkShadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkInputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkDividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkDividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: accentColor, width: 2),
        ),
        labelStyle: const TextStyle(color: darkTextSecondary),
        hintStyle: const TextStyle(color: darkTextTertiary),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: darkIconColor,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: darkTextPrimary),
        displayMedium: TextStyle(color: darkTextPrimary),
        displaySmall: TextStyle(color: darkTextPrimary),
        headlineLarge: TextStyle(color: darkTextPrimary),
        headlineMedium: TextStyle(color: darkTextPrimary),
        headlineSmall: TextStyle(color: darkTextPrimary),
        titleLarge: TextStyle(color: darkTextPrimary),
        titleMedium: TextStyle(color: darkTextPrimary),
        titleSmall: TextStyle(color: darkTextSecondary),
        bodyLarge: TextStyle(color: darkTextPrimary),
        bodyMedium: TextStyle(color: darkTextPrimary),
        bodySmall: TextStyle(color: darkTextSecondary),
        labelLarge: TextStyle(color: darkTextPrimary),
        labelMedium: TextStyle(color: darkTextSecondary),
        labelSmall: TextStyle(color: darkTextTertiary),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCardBackground,
        selectedItemColor: accentColor,
        unselectedItemColor: darkTextTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Drawer theme
      drawerTheme: const DrawerThemeData(
        backgroundColor: darkCardBackground,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: textWhite,
        elevation: 4,
      ),

      // Snackbar theme
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: darkCardBackgroundElevated,
        contentTextStyle: TextStyle(color: darkTextPrimary),
        actionTextColor: accentColor,
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: darkCardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        titleTextStyle: const TextStyle(
          color: darkTextPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: darkTextSecondary,
          fontSize: 16,
        ),
      ),

      // Popup menu theme
      popupMenuTheme: PopupMenuThemeData(
        color: darkCardBackgroundElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: darkTextPrimary),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: darkCardBackgroundElevated,
        deleteIconColor: darkTextSecondary,
        disabledColor: darkInputBackground,
        selectedColor: accentColor.withValues(alpha: 0.3),
        secondarySelectedColor: accentColor.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: darkTextPrimary),
        secondaryLabelStyle: const TextStyle(color: darkTextSecondary),
        brightness: Brightness.dark,
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return darkTextTertiary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor.withValues(alpha: 0.5);
          }
          return darkInputBackground;
        }),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(textWhite),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentColor;
          }
          return darkTextSecondary;
        }),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentColor,
        linearTrackColor: darkInputBackground,
        circularTrackColor: darkInputBackground,
      ),

      // Color scheme
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: accentColor,
        onPrimary: textWhite,
        primaryContainer: Color(0xFF8B0028),
        onPrimaryContainer: textWhite,
        secondary: primaryColor,
        onSecondary: textWhite,
        secondaryContainer: Color(0xFF2C2C2C),
        onSecondaryContainer: darkTextPrimary,
        tertiary: darkInfoColor,
        onTertiary: textWhite,
        error: darkErrorColor,
        onError: textWhite,
        errorContainer: Color(0xFF93000A),
        onErrorContainer: Color(0xFFFFDAD6),
        surface: scaffoldBackgroundColorDark,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkCardBackground,
        onSurfaceVariant: darkTextSecondary,
        outline: darkDividerColor,
        outlineVariant: Color(0xFF4A4A4A),
        shadow: Color(0xFF000000),
        scrim: Color(0xFF000000),
        inverseSurface: Color(0xFFE6E1E5),
        onInverseSurface: Color(0xFF313033),
        inversePrimary: accentColor,
        surfaceTint: accentColor,
      ),
    );
  }
}