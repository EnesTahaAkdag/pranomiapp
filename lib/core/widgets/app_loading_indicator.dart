import 'package:flutter/cupertino.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

/// Centralized loading indicator widget for consistent loading states across the app
///
/// This widget wraps the loading animation with consistent sizing and coloring.
/// Use this widget instead of directly using LoadingAnimationWidget to ensure
/// a consistent user experience throughout the application.
///
/// Example usage:
/// ```dart
/// // Default size (50px) and color (AppTheme.accentColor)
/// const AppLoadingIndicator()
///
/// // Custom size
/// const AppLoadingIndicator(size: AppConstants.loadingIndicatorSizeSmall)
///
/// // Custom color
/// AppLoadingIndicator(color: Colors.blue)
/// ```
class AppLoadingIndicator extends StatelessWidget {
  /// The size of the loading indicator
  /// Defaults to [AppConstants.loadingIndicatorSize] (50px)
  final double size;

  /// The color of the loading indicator
  /// Defaults to [AppTheme.accentColor]
  final Color? color;

  const AppLoadingIndicator({
    super.key,
    this.size = AppConstants.loadingIndicatorSize,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.staggeredDotsWave(
      color: color ?? AppTheme.accentColor,
      size: size,
    );
  }
}