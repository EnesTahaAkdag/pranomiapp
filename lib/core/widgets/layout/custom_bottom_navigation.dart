import 'package:flutter/material.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'bottom_nav_item.dart';
import 'bottom_sheet_menus.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final String currentRoute;
  final Function(String) onNavigate;
  final Function(int) onIndexChanged;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.currentRoute,
    required this.onNavigate,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.appBarDarkBackground,
        boxShadow: [
          BoxShadow(
            color: AppTheme.blackOverlay10,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottomNavItem(
                icon: Icons.home_rounded,
                label: 'Ana Sayfa',
                index: 0,
                isSelected: currentIndex == 0,
                onTap: () => onNavigate('/'),
              ),
              BottomNavItem(
                icon: Icons.attach_money_rounded,
                label: 'Gelirler',
                index: 1,
                isSelected: currentIndex == 1,
                onTap: () async {
                  await BottomSheetMenus.showIncomeSubMenu(
                    context,
                    currentRoute,
                    onNavigate,
                  );
                  onIndexChanged(1);
                },
              ),
              BottomNavItem(
                icon: Icons.money_off_rounded,
                label: 'Giderler',
                index: 2,
                isSelected: currentIndex == 2,
                onTap: () async {
                  await BottomSheetMenus.showExpenseSubMenu(
                    context,
                    currentRoute,
                    onNavigate,
                  );
                  onIndexChanged(2);
                },
              ),
              BottomNavItem(
                icon: Icons.description_rounded,
                label: 'E-Belgeler',
                index: 3,
                isSelected: currentIndex == 3,
                onTap: () async {
                  await BottomSheetMenus.showEDocumentsSubMenu(
                    context,
                    currentRoute,
                    onNavigate,
                  );
                  onIndexChanged(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}