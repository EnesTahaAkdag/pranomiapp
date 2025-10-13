import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/router/app_router.dart';
import 'package:pranomiapp/core/services/auth_service.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';

void main() async {
  // Setup dependency injection
  setupLocator();

  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Turkish locale for date formatting
  await initializeDateFormatting('tr_TR', null);

  // Configure system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: AppTheme.statusBarColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Run the app
  runApp(const PranomiApp());
}

class PranomiApp extends StatelessWidget {
  const PranomiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        // Show loading indicator while checking authentication
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        // Get login status
        final isLoggedIn = snapshot.data ?? false;

        // Create router with authentication state
        final router = AppRouter.createRouter(
          isLoggedIn: isLoggedIn,
          onLogout: (context) => AuthService.logout(),
        );

        // Return MaterialApp with router configuration
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Pranomi',
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [],
          supportedLocales: const [Locale('tr')],
          routerConfig: router,
        );
      },
    );
  }
}
