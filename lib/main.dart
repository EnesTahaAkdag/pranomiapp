import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/router/app_router.dart';
import 'package:pranomiapp/core/services/auth_service.dart';
import 'package:pranomiapp/core/services/fcm_service.dart';
import 'package:pranomiapp/core/services/local_notification_service.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';


void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  setupLocator();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize FCM service
  final fcmService = locator<FcmService>();
  await fcmService.initialize();

  // Initialize local notifications
  final localNotificationService = locator<LocalNotificationService>();
  await localNotificationService.initialize();
  await localNotificationService.createNotificationChannel();

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

        // Return MaterialApp with router configuration and builder to initialize FCM
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Pranomi',
          theme: AppTheme.lightTheme,
          localizationsDelegates: const [],
          supportedLocales: const [Locale('tr')],
          routerConfig: router,
          builder: (context, child) {
            // Initialize FCM notification handlers with context
            _initializeFcmHandlers(context);
            return child ?? const SizedBox();
          },
        );
      },
    );
  }

  bool _fcmInitialized = false;

  void _initializeFcmHandlers(BuildContext context) {
    // Initialize only once
    if (_fcmInitialized) return;
    _fcmInitialized = true;

    // Initialize FCM notification handlers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupFcmHandlers(context);
    });
  }

  void _setupFcmHandlers(BuildContext context) {
    final fcmService = locator<FcmService>();
    final localNotificationService = locator<LocalNotificationService>();

    // Handle foreground messages - show local notification
    fcmService.onForegroundMessage = (message) {
      debugPrint('📱 FOREGROUND notification received');
      debugPrint('Title: ${message.notification?.title}');
      debugPrint('Body: ${message.notification?.body}');

      // Show local notification when app is in foreground
      localNotificationService.showNotificationFromFirebase(message);
    };

    // Handle notification taps from background/terminated
    fcmService.onNotificationTap = (message) {
      debugPrint('👆 Notification TAPPED');
      debugPrint('Data: ${message.data}');

      // Handle navigation based on data
      _handleNotificationNavigation(context, message);
    };

    // Handle local notification taps
    localNotificationService.onNotificationTap = (payload) {
      if (payload == null) return;
      debugPrint('👆 Local notification TAPPED');
      debugPrint('Payload: $payload');

      // Parse payload and navigate
      _handleLocalNotificationTap(context, payload);
    };

    debugPrint('✅ FCM handlers initialized');
  }

  void _handleNotificationNavigation(BuildContext context, RemoteMessage message) {
    final data = message.data;
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

  void _handleLocalNotificationTap(BuildContext context, String payload) {
    // Parse payload into data map
    final data = <String, dynamic>{};
    final pairs = payload.split('&');
    for (final pair in pairs) {
      if (pair.isEmpty) continue;
      final keyValue = pair.split('=');
      if (keyValue.length == 2) {
        data[keyValue[0]] = keyValue[1];
      }
    }

    // Use same navigation logic
    _handleNotificationNavigation(context, RemoteMessage(data: data));
  }
}
