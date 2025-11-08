import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../di/injection.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    final prefs = locator<SharedPreferences>();
    await prefs.remove('apiKey');
    await prefs.remove('apiSecret');
    await prefs.remove('subscriptionType');
    await prefs.remove('isEInvoiceActive');
    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text("Çıkış Yap"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.buttonErrorColor,
              foregroundColor: AppTheme.white,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacingM),
            ),
          ),
        ],
      ),
    );
  }
}
