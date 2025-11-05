import 'package:flutter/material.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/app_constants.dart';

class BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingXs),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.selectedItemColor : AppTheme.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusM),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: AppConstants.iconSizeMedium,
                color: isSelected ? AppTheme.white : AppTheme.unselectedColor,
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeXxs,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.white : AppTheme.unselectedColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}