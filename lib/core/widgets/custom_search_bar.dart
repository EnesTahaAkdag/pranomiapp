import 'package:flutter/material.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final Color backgroundColor;
  final IconData prefixIcon;
  final BorderRadius borderRadius;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    this.hintText = 'Ara...',
    this.onClear,
    this.onSubmitted,
    this.onChanged,
    this.backgroundColor = AppTheme.white,
    this.prefixIcon = Icons.search,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Color(0xFF424242)),
      decoration: InputDecoration(
        filled: true,
        fillColor: Color(0xFFFFFFFF),
        prefixIcon: Icon(prefixIcon,color: const Color(0xFF1976D2),),
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF757575)),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.close,),
          onPressed: onClear,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: borderRadius,

        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}