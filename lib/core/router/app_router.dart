import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/features/customers/domain/customer_type_enum.dart';
import 'package:pranomiapp/features/accounting/presentation/pages/account_deposit_and_banks.dart';
import 'package:pranomiapp/features/customers/presentation/pages/customer_add_page.dart';
import 'package:pranomiapp/features/customers/presentation/pages/customer_edit_page.dart';
import 'package:pranomiapp/features/customers/presentation/pages/customer_page.dart';
import 'package:pranomiapp/features/invoices/presentation/pages/invoice_details.dart';
import 'package:pranomiapp/features/invoices/presentation/pages/invoices_claim_page.dart';
import 'package:pranomiapp/features/invoices/presentation/pages/invoices_page.dart';
import 'package:pranomiapp/core/widgets/layout/layout.dart';
import 'package:pranomiapp/core/router/route_titles.dart';
import 'package:pranomiapp/features/announcement/presentation/announcement_page.dart';
import 'package:pranomiapp/features/authentication/presentation/login_page.dart';
import 'package:pranomiapp/features/credit/presentation/credit_page.dart';
import 'package:pranomiapp/features/dashboard/presentation/dashboard_page.dart';
import 'package:pranomiapp/features/e_invoice/presentation/e_invoice_page.dart';
import 'package:pranomiapp/features/employees/presentation/pages/employee_add_page.dart';
import 'package:pranomiapp/features/employees/presentation/pages/employees_page.dart';
import 'package:pranomiapp/features/notifications/presentation/notifications_page.dart';
import 'package:pranomiapp/features/products/presentation/products_and_services_page.dart';
import 'package:pranomiapp/features/sms_verification/presentation/sms_verification_page.dart';
import 'package:pranomiapp/features/two_factor_auth/presentation/two_factor_auth_page.dart';

class AppRouter {
  static GoRouter createRouter({
    required bool isLoggedIn,
    required Future<void> Function(BuildContext) onLogout,
  }) {
    return GoRouter(
      initialLocation: isLoggedIn ? '/' : '/login',
      routes: [
        // Login Route
        GoRoute(
          path: '/login',
          builder: (context, state) {
            onLogout(context);
            return const LoginPage();
          },
        ),

        // Shell Route - Routes with AppLayout
        ShellRoute(
          builder: (context, state, child) => AppLayout(
            body: child,
            title: RouteTitles.getTitleForRoute(state.uri.path),
          ),
          routes: [
            // Dashboard
            GoRoute(
              path: '/',
              builder: (_, __) => const DashboardPage(),
            ),

            // Products and Services
            GoRoute(
              path: '/ProductsandServices',
              builder: (_, __) => const ProductsAndServicesPage(),
            ),

            // Invoice Routes - Expense
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

            // Invoice Routes - Income
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

            // E-Invoice Routes - Approved
            GoRoute(
              path: '/ApprovedE-Dispatch',
              builder: (_, __) => const EInvoicesPage(
                invoiceType: "eDespacth",
                recordType: "approved",
              ),
            ),
            GoRoute(
              path: '/ApprovedE-Invoice',
              builder: (_, __) => const EInvoicesPage(
                invoiceType: "eInvoice",
                recordType: "approved",
              ),
            ),

            // E-Invoice Routes - Outgoing
            GoRoute(
              path: '/OutGoingE-Dispatch',
              builder: (_, __) => const EInvoicesPage(
                invoiceType: "eDespacth",
                recordType: "outgoing",
              ),
            ),
            GoRoute(
              path: '/OutGoingE-Archive',
              builder: (_, __) => const EInvoicesPage(
                invoiceType: "eArchive",
                recordType: "outgoing",
              ),
            ),
            GoRoute(
              path: '/OutGoingE-Invoice',
              builder: (_, __) => const EInvoicesPage(
                invoiceType: "eInvoice",
                recordType: "outgoing",
              ),
            ),

            // Account Routes
            GoRoute(
              path: '/CustomerAccounts',
              builder: (_, __) => const CustomerPage(
                customerType: CustomerTypeEnum.Customer,
              ),
            ),
            GoRoute(
              path: '/EmployeAccounts',
              builder: (_, __) => const EmployeesPage(
                customerType: CustomerTypeEnum.Employee,
              ),
            ),
            GoRoute(
              path: '/SupplierAccounts',
              builder: (_, __) => const CustomerPage(
                customerType: CustomerTypeEnum.Supplier,
              ),
            ),
            GoRoute(
              path: "/DepositAndBanks",
              builder: (context, state) => const AccountDepositAndBanksPage(),
            ),

            // Other Routes
            GoRoute(
              path: '/Announcements',
              builder: (context, state) => AnnouncementPage(),
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

        // Routes outside ShellRoute (no AppLayout)
        GoRoute(
          path: '/sms-verification',
          builder: (context, state) {
            // Handle both test mode (String) and production mode (Map)
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              final userId = extra['userId'] as int;
              final gsmNumber = extra['gsmNumber'] as String;
              return SmsVerificationPage(
                phoneNumber: gsmNumber,
                userId: userId,
                gsmNumber: gsmNumber,
              );
            } else {
              // Test mode with just phone number
              final phoneNumber = extra as String? ?? '+905551234567';
              return SmsVerificationPage(phoneNumber: phoneNumber);
            }
          },
        ),
        GoRoute(
          path: '/two-factor-auth',
          builder: (context, state) {
            // Handle both test mode (String) and production mode (Map)
            final extra = state.extra;
            if (extra is Map<String, dynamic>) {
              final userId = extra['userId'] as int;
              final gsmNumber = extra['gsmNumber'] as String;
              return TwoFactorAuthPage(
                phoneNumber: gsmNumber,
                userId: userId,
                gsmNumber: gsmNumber,
              );
            } else {
              // Test mode with just phone number
              final phoneNumber = extra as String? ?? '+905551234567';
              return TwoFactorAuthPage(phoneNumber: phoneNumber);
            }
          },
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
  }
}