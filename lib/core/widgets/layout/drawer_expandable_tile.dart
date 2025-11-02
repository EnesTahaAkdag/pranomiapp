import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';

class DrawerExpandableTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String id;
  final bool isExpanded;
  final Function(String) onToggle;
  final List<Widget> children;

  const DrawerExpandableTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.id,
    required this.isExpanded,
    required this.onToggle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      // Smaller, more compact icon
      leading: SvgPicture.asset(
        'lib/assets/images/$imagePath',
        width: 24,
        height: 24,
        alignment: Alignment.center,
        colorFilter: const ColorFilter.mode(AppTheme.deepOrange, BlendMode.srcIn),
      ),
      // Smaller, responsive text
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppTheme.mediumGrayBackground,
      collapsedBackgroundColor: AppTheme.darkGrayBackground,
      iconColor: AppTheme.white,
      collapsedIconColor: AppTheme.white,
      initiallyExpanded: isExpanded,
      onExpansionChanged: (_) => onToggle(id),
      // Compact density for smaller height
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
      visualDensity: VisualDensity.compact,
      // Reduce spacing between title and children
      childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 4),
      children: children,
    );
  }
}