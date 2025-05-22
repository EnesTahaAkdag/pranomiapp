import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/Pages/HomesPage.dart';
import 'package:pranomiapp/Pages/SharedPage/Layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/Pages/AuthenticationPage/LoginPage.dart';
import 'package:pranomiapp/Pages/InvocesPages/InvoicePages/InvoicesPage.dart';
import 'package:pranomiapp/Pages/InvocesPages/InvoicePages/InvoiceDetails.dart';
import 'package:pranomiapp/Pages/EInvoicesPages/EInvoicePage/EInvoicePage.dart';
import 'package:pranomiapp/Pages/InvocesPages/InvoicesClaimPage/InvoicesClaimPage.dart';
import 'package:pranomiapp/Pages/StockPages/ProductsAndServicesPage/ProductsandServicesPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.delayed(Duration(milliseconds: 1500));
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 41, 41, 41),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? apiKey = prefs.getString('apiKey');
    String? apiSecret = prefs.getString('apiSecret');
    return apiKey != null && apiSecret != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        final router = GoRouter(
          initialLocation: isLoggedIn ? '/' : '/login',
          routes: [
            GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
            ShellRoute(
              builder:
                  (context, state, child) => AppLayout(
                    body: child,
                    title: _getTitleForRoute(state.uri.path),
                  ),
              routes: [
                GoRoute(path: '/', builder: (_, __) => const HomePage()),

                GoRoute(
                  path: '/products',
                  builder: (_, __) => const ProductsandServicesPage(),
                ),

                GoRoute(
                  path: '/expenseclaim',
                  builder: (_, __) => const InvoicesClaimPage(claimType: 2),
                ),

                GoRoute(
                  path: '/expenseinvoice',
                  builder: (_, __) => const InvoicesPage(invoiceType: 2),
                ),

                GoRoute(
                  path: '/expenseorder',
                  builder: (_, __) => const InvoicesPage(invoiceType: 4),
                ),

                GoRoute(
                  path: '/expensewaybill',
                  builder: (_, __) => const InvoicesPage(invoiceType: 6),
                ),

                GoRoute(
                  path: '/incomeclaim',
                  builder: (_, __) => const InvoicesClaimPage(claimType: 1),
                ),

                GoRoute(
                  path: '/incomeinvoice',
                  builder: (_, __) => const InvoicesPage(invoiceType: 1),
                ),

                GoRoute(
                  path: '/incomeorder',
                  builder: (_, __) => const InvoicesPage(invoiceType: 3),
                ),

                GoRoute(
                  path: '/incomewaybill',
                  builder: (_, __) => const InvoicesPage(invoiceType: 5),
                ),

                GoRoute(
                  path: '/approvededispatch',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eDespacth",
                        recordType: "approved",
                      ),
                ),

                GoRoute(
                  path: '/approvedeinvoice',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eInvoice",
                        recordType: "approved",
                      ),
                ),

                GoRoute(
                  path: '/outgoingedispatch',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eDespacth",
                        recordType: "outgoing",
                      ),
                ),

                GoRoute(
                  path: '/outgoingearchive',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eArchive",
                        recordType: "outgoing",
                      ),
                ),

                GoRoute(
                  path: '/outgoingeinvoice',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eInvoice",
                        recordType: "outgoing",
                      ),
                ),
              ],
            ),
            GoRoute(
              path: '/invoice-detail/:id',
              builder: (context, state) {
                final invoiceId = int.parse(state.pathParameters['id']!);
                return InvoiceDetailPage(invoiceId: invoiceId);
              },
            ),
          ],
        );

        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF3D3D3D),
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF3D3D3D),
              elevation: 0,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB00034),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          localizationsDelegates: const [],
          supportedLocales: const [Locale('tr')],
          routerConfig: router,
        );
      },
    );
  }

  String _getTitleForRoute(String path) {
    switch (path) {
      case '/':
        return 'Genel Bakış';

      case '/products':
        return 'Ürünler ve Hizmetler';

      case '/incomeinvoice':
        return 'Gelen Faturalar';

      case '/expenseinvoice':
        return 'Giden Faturalar';

      case '/incomeorder':
        return 'Gelen Siparişler';

      case '/expenseorder':
        return 'Giden Siparişler';

      case '/incomewaybill':
        return 'Gelen İrsaliyeler';

      case '/incomeclaim':
        return 'Satış İade Faturası';

      case '/expenseclaim':
        return 'Alış İade Faturası';

      case '/expensewaybill':
        return 'Giden İrsaliyeler';

      case '/approvededispatch':
        return 'Gelen E-İrsaliyeler';

      case '/approvedeinvoice':
        return 'Gelen E-Faturalar';

      case '/outgoingedispatch':
        return 'Gide E-İrsaliyeler';

      case '/outgoingearchive':
        return 'Giden E-Arşiv Faturalar';

      case '/outgoingeinvoice':
        return 'Giden E-Faturalar';

      default:
        return 'Sayfa';
    }
  }
}
