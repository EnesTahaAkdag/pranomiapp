import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_constants.dart';

/// A reusable phone number text field widget with formatting and validation
class PhoneTextField extends StatelessWidget {
  final String label;
  final void Function(String?) onSaved;
  final String? Function(String?)? validator;
  final String? initialValue;

  const PhoneTextField({
    super.key,
    required this.label,
    required this.onSaved,
    this.validator,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.spacing12),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          hintText: '(5XX) XXX XX XX',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.fontSizeM,
          ),
        ),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          PhoneNumberFormatter(),
        ],
        validator: validator,
        onSaved: (value) => onSaved(value?.unformatPhoneNumber()),
      ),
    );
  }

}

/// Text input formatter for phone numbers in the format (5XX) XXX XX XX
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.length > 10) {
      text = text.substring(0, 10);
    }

    String formatted = '';

    if (text.isNotEmpty) {
      formatted = '(${text.substring(0, text.length.clamp(0, 3))}';

      if (text.length > 3) {
        formatted += ') ${text.substring(3, text.length.clamp(3, 6))}';
      }

      if (text.length > 6) {
        formatted += ' ${text.substring(6, text.length.clamp(6, 8))}';
      }

      if (text.length > 8) {
        formatted += ' ${text.substring(8, text.length.clamp(8, 10))}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Extension methods for phone number string manipulation
extension PhoneNumberExtension on String {
  /// Formats a 10-digit phone number string to (XXX) XXX XX XX format
  String formatPhoneNumber() {
    String cleaned = replaceAll(RegExp(r'\D'), '');
    if (cleaned.length != 10) return this;
    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
  }

  /// Removes all non-digit characters from a phone number string
  String unformatPhoneNumber() {
    return replaceAll(RegExp(r'\D'), '');
  }
}
