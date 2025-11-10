import 'package:flutter/material.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/app_constants.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final IconData prefixIcon;
  final BorderRadius borderRadius;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'Ara...',
    this.onClear,
    this.onSubmitted,
    this.onChanged,
    this.prefixIcon = Icons.search,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppConstants.borderRadiusBottomSheet)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: AppTheme.textMedium2),
      decoration: InputDecoration(
        filled: true,
        prefixIcon: Icon(prefixIcon, color: AppTheme.searchIconColor),
        hintText: hintText,
        hintStyle: const TextStyle(color: AppTheme.textGrayLight),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClear,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
      ),
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}