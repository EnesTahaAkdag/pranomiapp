import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
      color: isActive ? const Color(0xFFB00034) : Colors.transparent,
      child: ListTile(
        leading: SvgPicture.asset(
          'lib/assets/images/$imagePath',
          width: 32,
          height: 32,
          alignment: Alignment.center,
          colorFilter: const ColorFilter.mode(Colors.deepOrange, BlendMode.srcIn),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        tileColor: isActive ? const Color(0xFFB00034) : Colors.transparent,
        onTap: () => onTap(route),
      ),
    );
  }
}