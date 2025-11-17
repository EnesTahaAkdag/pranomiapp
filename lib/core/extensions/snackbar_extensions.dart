import 'package:flutter/material.dart';

extension SnackbarExtensions on BuildContext{
  SnackBar showSuccessSnackbar(String message) {
    return SnackBar(content: Text(message), backgroundColor: Colors.green);
  }
}