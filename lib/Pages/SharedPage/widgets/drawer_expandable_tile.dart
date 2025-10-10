import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
        colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
      ),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      backgroundColor: const Color(0xFF2C2C2C),
      collapsedBackgroundColor: const Color(0xFF3F3F3F),
      iconColor: Colors.white,
      collapsedIconColor: Colors.white,
      initiallyExpanded: isExpanded,
      onExpansionChanged: (_) => onToggle(id),
      children: children,
    );
  }
}