import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/app_constants.dart';

class DrawerMenuItem extends StatelessWidget {
  final String imagePath;
  final String title;
  final String route;
  final String currentRoute;
  final Function(String) onTap;

  const DrawerMenuItem({
    super.key,
    required this.imagePath,
    required this.title,
    required this.route,
    required this.currentRoute,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = route == currentRoute;

    return Container(
      color: isActive ? AppTheme.accentColor : AppTheme.transparent,
      child: ListTile(
        // Smaller, more compact icon (matches DrawerExpandableTile)
        leading: SvgPicture.asset(
          'lib/assets/images/$imagePath',
          width: AppConstants.iconSizeM,
          height: AppConstants.iconSizeM,
          alignment: Alignment.center,
          colorFilter: const ColorFilter.mode(AppTheme.deepOrange, BlendMode.srcIn),
        ),
        // Smaller, responsive text (matches DrawerExpandableTile)
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.white,
            fontSize: AppConstants.fontSizeM,
            fontWeight: FontWeight.w500,
          ),
        ),
        tileColor: isActive ? AppTheme.accentColor : AppTheme.transparent,
        // Compact padding (matches DrawerExpandableTile)
        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM, vertical: AppConstants.spacingXs),
        dense: true,
        visualDensity: VisualDensity.compact,
        onTap: () => onTap(route),
      ),
    );
  }
}