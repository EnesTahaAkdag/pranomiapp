import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/Pages/EInvoicePages/IncomeeEInvoicePages/IncomeeDispatchPage/IncomeeDispatchPage.dart';
import 'package:pranomiapp/Pages/EInvoicePages/IncomeeEInvoicePages/IncomeeInvoicePage/IncomeeInvoicePage.dart';
import 'package:pranomiapp/Pages/HomesPage.dart';
import 'package:pranomiapp/Pages/SharedPage/Layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/Pages/AuthenticationPage/LoginPage.dart';
import 'package:pranomiapp/Pages/StockPages/ProductPage/ProductPage.dart';
import 'package:pranomiapp/Pages/IncomesPage/IncomeClaimPage/IncomeClaimPage.dart';
import 'package:pranomiapp/Pages/IncomesPage/IncomeOrdersPage/IncomeOrdersPage.dart';
import 'package:pranomiapp/Pages/StockPages/IncomeWayBillPage/IncomeWayBillPage.dart';
import 'package:pranomiapp/Pages/ExpensesPages/ExpenseClaimPage/ExpenseClaimPage.dart';
import 'package:pranomiapp/Pages/IncomesPage/IncomeInvoicePage/IncomeInvoicePage.dart';
import 'package:pranomiapp/Pages/StockPages/ExpenseWayBillPage/ExpenseWayBillPage.dart';
import 'package:pranomiapp/Pages/ExpensesPages/ExpenseOrdersPage/ExpenseOrdersPage.dart';
import 'package:pranomiapp/Pages/ExpensesPages/ExpenseInvoicePage/ExpenseInvoicePage.dart';
import 'package:pranomiapp/Pages/EInvoicePages/ExpenseEInvoicePages/ExpenseeDispatchPage/ExopenseeDispatchPage.dart';
import 'package:pranomiapp/Pages/EInvoicePages/ExpenseEInvoicePages/ExpenseeArchivePage/ExpenseeArchivePage.dart';
import 'package:pranomiapp/Pages/EInvoicePages/ExpenseEInvoicePages/ExpenseeInvoicePage/ExpenseeInvoicePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
                GoRoute(path: '/', builder: (_, __) => const HomeScreen()),

                GoRoute(
                  path: '/products',
                  builder: (_, __) => const ProductPage(),
                ),

                GoRoute(
                  path: '/expenseclaim',
                  builder: (_, __) => const ExpenseClaimPage(),
                ),

                GoRoute(
                  path: '/expenseinvoice',
                  builder: (_, __) => const ExpenseInvoicePage(),
                ),

                GoRoute(
                  path: '/expenseorder',
                  builder: (_, __) => const ExpenseOrdersPage(),
                ),

                GoRoute(
                  path: '/incomeorder',
                  builder: (_, __) => const IncomeOrdersPage(),
                ),

                GoRoute(
                  path: '/incomeclaim',
                  builder: (_, __) => const IncomeClaimPage(),
                ),

                GoRoute(
                  path: '/incomeinvoice',
                  builder: (_, __) => const IncomeInvoicePage(),
                ),

                GoRoute(
                  path: '/expensewaybill',
                  builder: (_, __) => const ExpenseWillBillPage(),
                ),

                GoRoute(
                  path: '/incomewaybill',
                  builder: (_, __) => const IncomeWayBillPage(),
                ),

                GoRoute(
                  path: '/incomeedispatch',
                  builder: (_, __) => const IncomeEDispatchPage(),
                ),

                GoRoute(
                  path: '/incomeeinvoice',
                  builder: (_, __) => const IncomeEInvoicePage(),
                ),

                GoRoute(
                  path: '/expenseedispatch',
                  builder: (_, __) => const ExpenseEDispatchPage(),
                ),

                GoRoute(
                  path: '/expenseearchive',
                  builder: (_, __) => const ExpenseEArchivePage(),
                ),

                GoRoute(
                  path: '/expenseeinvoice',
                  builder: (_, __) => const ExpenseEInvoicePage(),
                ),
              ],
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

      case '/expenseinvoices':
        return 'Giden Faturalar';

      case '/incomeorders':
        return 'Gelen Siparişler';

      case '/expenseorders':
        return 'Giden Siparişler';

      case '/incomewaybill':
        return 'Gelen İrsaliyeler';

      case '/incomeclaim':
        return 'Satış İade Faturası';

      case '/expenseclaim':
        return 'Alış İade Faturası';

      case '/expensewaybill':
        return 'Giden İrsaliyeler';

      case '/incomeedispatch':
        return 'E-İrsaliyeler';

      case '/incomeeinvoice':
        return 'E-Faturalar';

      case '/expenseedispatch':
        return 'E-İrsaliyeler';

      case '/expenseearchive':
        return 'E-Arşiv Faturalar';

      case '/expenseeinvoice':
        return 'E-Faturalar';

      default:
        return 'Sayfa';
    }
  }
}
