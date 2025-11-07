/// Centralized UI constants for the Pranomi app
/// This file contains all magic numbers and hardcoded values used across the app
/// to maintain consistency and make updates easier.
class AppConstants {
  AppConstants._();

  // ============================================================================
  // LOADING INDICATOR CONSTANTS
  // ============================================================================

  /// Default size for loading indicators across the app
  static const double loadingIndicatorSize = 50.0;

  /// Small loading indicator size (for compact areas)
  static const double loadingIndicatorSizeSmall = 30.0;

  /// Large loading indicator size (for full-screen loading)
  static const double loadingIndicatorSizeLarge = 70.0;

  static const int loadingAnimationDuration = 1;


  // ============================================================================
  // SPACING CONSTANTS
  // ============================================================================

  /// Extra small spacing (4px)
  static const double spacingXs = 4.0;

  /// Small spacing (8px)
  static const double spacingS = 8.0;

  /// Medium spacing (16px)
  static const double spacingM = 16.0;

  /// Large spacing (24px)
  static const double spacingL = 24.0;

  /// Extra large spacing (32px)
  static const double spacingXl = 32.0;

  // Additional specific spacing values
  /// 5px spacing
  static const double spacing5 = 5.0;

  /// 6px spacing
  static const double spacing6 = 6.0;

  /// 10px spacing
  static const double spacing10 = 10.0;

  /// 12px spacing
  static const double spacing12 = 12.0;

  /// 15px spacing
  static const double spacing15 = 15.0;

  /// 20px spacing
  static const double spacing20 = 20.0;

  /// 28px spacing
  static const double spacing28 = 28.0;

  /// 30px spacing
  static const double spacing30 = 30.0;

  /// 40px spacing
  static const double spacing40 = 40.0;

  /// 48px spacing
  static const double spacing48 = 48.0;

  // ============================================================================
  // BORDER RADIUS CONSTANTS
  // ============================================================================

  /// Small border radius (8px)
  static const double borderRadiusS = 8.0;

  /// Medium border radius (12px)
  static const double borderRadiusM = 12.0;

  /// Large border radius (16px)
  static const double borderRadiusL = 16.0;

  /// Extra large border radius (24px) - for search bars and rounded elements
  static const double borderRadiusXl = 24.0;

  /// Circle border radius (for circular buttons)
  static const double borderRadiusCircle = 50.0;

  /// Border radius for bottom sheets (20px)
  static const double borderRadiusBottomSheet = 20.0;

  // ============================================================================
  // ELEVATION CONSTANTS
  // ============================================================================

  /// No elevation
  static const double elevationNone = 0.0;

  /// Low elevation (for subtle shadows)
  static const double elevationLow = 2.0;

  /// Medium elevation (for cards)
  static const double elevationMedium = 4.0;

  /// High elevation (for floating elements)
  static const double elevationHigh = 8.0;

  // ============================================================================
  // ICON SIZE CONSTANTS
  // ============================================================================

  /// Small icon size
  static const double iconSizeS = 16.0;

  /// Medium icon size (default)
  static const double iconSizeM = 24.0;

  /// Large icon size
  static const double iconSizeL = 32.0;

  /// Extra large icon size (for FAB and prominent actions)
  static const double iconSizeXl = 40.0;

  /// Icon size for bottom navigation (26px)
  static const double iconSizeMedium = 26.0;

  /// Extra extra large icon size (48px)
  static const double iconSizeXxl = 48.0;

  /// Icon size for large containers (80px)
  static const double iconSize80 = 80.0;

  // ============================================================================
  // FONT SIZE CONSTANTS
  // ============================================================================

  /// Font size for bottom nav labels (11px)
  static const double fontSizeXxs = 11.0;

  /// Extra small font size
  static const double fontSizeXs = 10.0;

  /// Small font size
  static const double fontSizeS = 12.0;

  /// Medium font size (body text)
  static const double fontSizeM = 14.0;

  /// Large font size (subtitles)
  static const double fontSizeL = 16.0;

  /// Extra large font size (titles)
  static const double fontSizeXl = 18.0;

  /// Extra extra large font size (headlines)
  static const double fontSizeXxl = 20.0;

  // ============================================================================
  // PAGINATION CONSTANTS
  // ============================================================================

  /// Default page size for paginated lists
  static const int defaultPageSize = 20;

  /// Scroll threshold for triggering pagination (pixels from bottom)
  static const double paginationScrollThreshold = 200.0;

  // ============================================================================
  // IMAGE SIZE CONSTANTS
  // ============================================================================

  /// Thumbnail image size
  static const double imageSizeThumbnail = 40.0;

  /// Small image size
  static const double imageSizeSmall = 60.0;

  /// Medium image size
  static const double imageSizeMedium = 80.0;

  /// Large image size
  static const double imageSizeLarge = 120.0;

  // ============================================================================
  // ANIMATION DURATION CONSTANTS
  // ============================================================================

  /// Fast animation duration (100ms)
  static const Duration animationDurationFast = Duration(milliseconds: 100);

  /// Normal animation duration (200ms)
  static const Duration animationDurationNormal = Duration(milliseconds: 200);

  /// Slow animation duration (300ms)
  static const Duration animationDurationSlow = Duration(milliseconds: 300);

  // ============================================================================
  // TIMEOUT CONSTANTS
  // ============================================================================

  /// API request timeout (10 seconds)
  static const Duration apiTimeout = Duration(seconds: 10);

  /// Short debounce delay (300ms) - for search input
  static const Duration debounceShort = Duration(milliseconds: 300);

  /// Medium debounce delay (500ms)
  static const Duration debounceMedium = Duration(milliseconds: 500);

  // ============================================================================
  // SNACKBAR DURATION CONSTANTS
  // ============================================================================

  /// Short SnackBar duration (2 seconds)
  static const Duration snackBarShort = Duration(seconds: 2);

  /// Normal SnackBar duration (3 seconds)
  static const Duration snackBarNormal = Duration(seconds: 3);

  /// Long SnackBar duration (5 seconds)
  static const Duration snackBarLong = Duration(seconds: 5);

  // ============================================================================
  // LOGO AND HEADER CONSTANTS
  // ============================================================================

  /// Standard logo height
  static const double logoHeight = 90.0;

  /// Large logo height (for login/splash screens)
  static const double logoHeightLarge = 100.0;

  /// Header padding top
  static const double headerPaddingTop = 50.0;

  /// Header padding bottom
  static const double headerPaddingBottom = 30.0;

  // ============================================================================
  // MISCELLANEOUS CONSTANTS
  // ============================================================================

  /// Currency decimal places
  static const int currencyDecimalPlaces = 2;

  /// Height multiplier for screen height calculations (e.g., 0.5 for 50% of screen)
  static const double screenHeightMultiplierHalf = 0.5;

  /// Opacity for disabled elements
  static const double opacityDisabled = 0.5;

  /// Opacity for semi-transparent overlays
  static const double opacityOverlay = 0.7;
}
