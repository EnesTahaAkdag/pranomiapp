import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/router/app_router.dart';
import 'package:pranomiapp/core/services/auth_service.dart';
import 'package:pranomiapp/core/services/theme_service.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection (including SharedPreferences singleton)
  await setupLocator();

  // Initialize OneSignal
  // Enable verbose logging for debugging (remove in production)
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

  // Initialize with your OneSignal App ID
  OneSignal.initialize("e387ed1b-302a-4c3f-a2b2-f768d2b0ade4");

  // Request notification permission
  OneSignal.Notifications.requestPermission(true);

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

class PranomiApp extends StatefulWidget {
  const PranomiApp({super.key});

  @override
  State<PranomiApp> createState() => _PranomiAppState();
}

class _PranomiAppState extends State<PranomiApp> {
  @override
  Widget build(BuildContext context) {
    // Get ThemeService instance
    final themeService = locator<ThemeService>();

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

        // Return MaterialApp with theme listener for dynamic theme switching
        return ListenableBuilder(
          listenable: themeService,
          builder: (context, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Pranomi',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeService.themeMode,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('tr', 'TR'),
              ],
              routerConfig: router,
              builder: (context, child) {
                // Initialize OneSignal notification handlers with context
                _initializeOneSignalHandlers(context);
                return child ?? const SizedBox();
              },
            );
          },
        );
      },
    );
  }

  bool _oneSignalInitialized = false;

  void _initializeOneSignalHandlers(BuildContext context) {
    // Initialize only once
    if (_oneSignalInitialized) return;
    _oneSignalInitialized = true;

    // Initialize OneSignal notification handlers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupOneSignalHandlers(context);
    });
  }

  void _setupOneSignalHandlers(BuildContext context) {
    // Set up notification click listener
    OneSignal.Notifications.addClickListener((event) {
      debugPrint('👆 OneSignal Notification CLICKED');
      debugPrint('Notification data: ${event.notification.additionalData}');

      // Handle navigation based on notification data
      if (context.mounted) {
        _handleNotificationNavigation(
          context,
          event.notification.additionalData ?? {},
        );
      }
    });

    // Set up foreground will display listener (optional)
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      debugPrint('📱 OneSignal FOREGROUND notification received');
      debugPrint('Title: ${event.notification.title}');
      debugPrint('Body: ${event.notification.body}');

      // Display the notification (you can customize this)
      event.notification.display();
    });

    debugPrint('✅ OneSignal handlers initialized');
  }

  void _handleNotificationNavigation(
    BuildContext context,
    Map<String, dynamic>? data,
  ) {
    if (data == null) return;

    final notificationType = data['notificationType'];
    final referenceNumber = data['referenceNumber'];

    debugPrint('Navigation - Type: $notificationType, Ref: $referenceNumber');

    // Navigate based on notification type
    if (notificationType != null && context.mounted) {
      switch (notificationType.toString()) {
        case '1': // Invoice
          if (referenceNumber != null) {
            context.push('/invoice/detail/$referenceNumber');
          } else {
            context.push('/invoices');
          }
          break;
        case '2': // E-Invoice
          if (referenceNumber != null) {
            context.push('/e-invoice/detail/$referenceNumber');
          } else {
            context.push('/e-invoices');
          }
          break;
        case '3': // Customer
          if (referenceNumber != null) {
            context.push('/customer/detail/$referenceNumber');
          } else {
            context.push('/customers');
          }
          break;
        case '4': // Credit
          context.push('/credit');
          break;
        case '5': // Announcement
          context.push('/announcements');
          break;
        case '6': // Product
          if (referenceNumber != null) {
            context.push('/product/detail/$referenceNumber');
          } else {
            context.push('/products');
          }
          break;
        default:
          context.push('/notifications');
      }
    }
  }
}
