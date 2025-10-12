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
      leading: SvgPicture.asset(
        'lib/assets/images/$imagePath',
        width: 32,
        height: 32,
        alignment: Alignment.center,
        colorFilter: const ColorFilter.mode(AppTheme.deepOrange, BlendMode.srcIn),
      ),
      title: Text(title, style: const TextStyle(color: AppTheme.white)),
      backgroundColor: AppTheme.mediumGrayBackground,
      collapsedBackgroundColor: AppTheme.darkGrayBackground,
      iconColor: AppTheme.white,
      collapsedIconColor: AppTheme.white,
      initiallyExpanded: isExpanded,
      onExpansionChanged: (_) => onToggle(id),
      children: children,
    );
  }
}