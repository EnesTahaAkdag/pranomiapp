import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/Pages/AccountPages/AccountPage/AcoountDepositAndBanks.dart';
import 'package:pranomiapp/core/di/Injection.dart';
import 'package:pranomiapp/Pages/HomesPage.dart';
import 'package:pranomiapp/Pages/SharedPage/Layout.dart';
import 'package:pranomiapp/features/credit/presentation/CreditPage.dart';
import 'package:pranomiapp/features/employees/EmployeeAddPage.dart';
import 'package:pranomiapp/features/employees/EmployeesPage.dart';
import 'package:pranomiapp/features/notifications/presentation/NotificationsPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/features/authentication/presentation/LoginPage.dart';
import 'package:pranomiapp/Pages/InvocesPages/InvoicePages/InvoicesPage.dart';
import 'package:pranomiapp/Pages/InvocesPages/InvoicePages/InvoiceDetails.dart';
import 'package:pranomiapp/Pages/CustomersPages/CustomerPage/CustomerPage.dart';
import 'package:pranomiapp/Pages/CustomersPages/CustomerPage/CustomerAddPage.dart';
import 'package:pranomiapp/Pages/InvocesPages/InvoicePages/InvoicesClaimPage.dart';
import 'package:pranomiapp/Pages/CustomersPages/CustomerPage/CustomerEditPage.dart';

import 'features/announcement/presentation/AnnouncementPage.dart';
import 'features/e_invoice/presentation/EInvoicePage.dart';
import 'features/products/presentation/ProductsAndServicesPage.dart';

void main() async {
  setupLocator();
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 41, 41, 41),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );

  runApp(const PranomiApp());
}

class PranomiApp extends StatelessWidget {
  const PranomiApp({super.key});

  static const getTitleForRoutes = {
    '/': 'Genel Bakış',
    '/ProductsandServices': 'Ürünler ve Hizmetler',
    '/InComeInvoice': 'Gelen Faturalar',
    '/ExpenseInvoice': 'Giden Faturalar',
    '/InComeOrder': 'Gelen Siparişler',
    '/ExpenseOrder': 'Giden Siparişler',
    '/IncomeWayBill': 'Gelen İrsaliyeler',
    '/InComeClaim': 'Satış İade Faturası',
    '/ExpenseClaim': 'Alış İade Faturası',
    '/ExpenseWayBill': 'Giden İrsaliyeler',
    '/ApprovedE-Dispatch': 'Gelen E-İrsaliyeler',
    '/ApprovedE-Invoice': 'Gelen E-Faturalar',
    '/OutGoingE-Dispatch': 'Gide E-İrsaliyeler',
    '/OutGoingE-Archive': 'Giden E-Arşiv Faturalar',
    '/OutGoingE-Invoice': 'Giden E-Faturalar',
    '/CustomerAccounts': 'Cari Hesaplar',
    '/EmployeAccounts': 'Çalışanlar',
    '/SupplierAccounts': 'Tedarikçiler',
    '/DepositAndBanks': 'Kasa Ve Bankalar',
    '/Announcements': 'Duyurular',
    '/Credits': 'Kontörlerim',
    '/Notifications': 'Bildirimler',
  };

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
                  path: '/ProductsandServices',
                  builder: (_, __) => const ProductsAndServicesPage(),
                ),

                GoRoute(
                  path: '/ExpenseClaim',
                  builder: (_, __) => const InvoicesClaimPage(claimType: 2),
                ),

                GoRoute(
                  path: '/ExpenseInvoice',
                  builder: (_, __) => const InvoicesPage(invoiceType: 2),
                ),

                GoRoute(
                  path: '/ExpenseOrder',
                  builder: (_, __) => const InvoicesPage(invoiceType: 4),
                ),

                GoRoute(
                  path: '/ExpenseWayBill',
                  builder: (_, __) => const InvoicesPage(invoiceType: 6),
                ),

                GoRoute(
                  path: '/InComeClaim',
                  builder: (_, __) => const InvoicesClaimPage(claimType: 1),
                ),

                GoRoute(
                  path: '/InComeInvoice',
                  builder: (_, __) => const InvoicesPage(invoiceType: 1),
                ),

                GoRoute(
                  path: '/InComeOrder',
                  builder: (_, __) => const InvoicesPage(invoiceType: 3),
                ),

                GoRoute(
                  path: '/IncomeWayBill',
                  builder: (_, __) => const InvoicesPage(invoiceType: 5),
                ),

                GoRoute(
                  path: '/ApprovedE-Dispatch',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eDespacth",
                        recordType: "approved",
                      ),
                ),

                GoRoute(
                  path: '/ApprovedE-Invoice',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eInvoice",
                        recordType: "approved",
                      ),
                ),

                GoRoute(
                  path: '/OutGoingE-Dispatch',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eDespacth",
                        recordType: "outgoing",
                      ),
                ),

                GoRoute(
                  path: '/OutGoingE-Archive',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eArchive",
                        recordType: "outgoing",
                      ),
                ),

                GoRoute(
                  path: '/OutGoingE-Invoice',
                  builder:
                      (_, __) => const EInvoicesPage(
                        invoiceType: "eInvoice",
                        recordType: "outgoing",
                      ),
                ),

                GoRoute(
                  path: '/CustomerAccounts',
                  builder:
                      (_, __) => const CustomerPage(
                        customerType: CustomerTypeEnum.Customer,
                      ),
                ),

                GoRoute(
                  path: '/EmployeAccounts',
                  builder:
                      (_, __) => const EmployeesPage(
                        customerType: CustomerTypeEnum.Employee,
                      ),
                ),

                GoRoute(
                  path: '/SupplierAccounts',
                  builder:
                      (_, __) => const CustomerPage(
                        customerType: CustomerTypeEnum.Supplier,
                      ),
                ),

                GoRoute(
                  path: "/DepositAndBanks",
                  builder: (context, state) {
                    return const AccountDepositAndBanksPage();
                  },
                ),

                GoRoute(
                  path: '/Announcements',
                  builder: (context, state) {
                    return AnnouncementPage();
                  },
                ),

                GoRoute(
                  path: '/Credits',
                  builder: (context, state) => const CreditPage(),
                ),

                GoRoute(
                  path: '/Notifications',
                  builder: (context, state) => const NotificationsPage(),
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

            GoRoute(
              path: '/CustomerAddPage',
              builder: (context, state) {
                return CustomerAddPage(customerType: CustomerTypeEnum.Customer);
              },
            ),

            GoRoute(
              path: '/EmployeeAddPage',
              builder: (context, state) {
                return EmployeeAddPage(customerType: CustomerTypeEnum.Employee);
              },
            ),

            GoRoute(
              path: '/CustomerEditPage',
              builder: (context, state) {
                final customerId = state.extra as int?;
                if (customerId == null) {
                  return const Scaffold(
                    body: Center(child: Text('Geçersiz müşteri ID')),
                  );
                }
                return CustomerEditPage(customerId: customerId);
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
    return getTitleForRoutes[path] ?? 'Sayfa';
  }
}
