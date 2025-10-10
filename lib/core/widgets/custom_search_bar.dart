import 'package:flutter/material.dart';

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
    this.backgroundColor = Colors.white,
    this.prefixIcon = Icons.search,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundColor,
        prefixIcon: Icon(prefixIcon),
        hintText: hintText,
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.close),
          onPressed: onClear,
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      onSubmitted: onSubmitted,
      onChanged: onChanged,
    );
  }
}