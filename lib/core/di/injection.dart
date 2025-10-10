import 'package:get_it/get_it.dart';
import 'package:pranomiapp/features/authentication/data/login_services.dart';
import 'package:pranomiapp/features/credit/data/credit_service.dart';
import 'package:pranomiapp/features/dashboard/data/dashboard_service.dart';
import 'package:pranomiapp/features/employees/employee_add_service.dart';
import 'package:pranomiapp/features/employees/employees_service.dart';
import 'package:pranomiapp/features/notifications/data/notifications_service.dart';
import 'package:pranomiapp/services/AccountServers/account_service.dart';
import 'package:pranomiapp/services/CustomerService/customer_add_service.dart';
import 'package:pranomiapp/services/CustomerService/customer_detail_service.dart';
import 'package:pranomiapp/services/CustomerService/customer_edit_service.dart';
import 'package:pranomiapp/services/CustomerService/customer_service.dart';
import 'package:pranomiapp/services/EInvoiceService/e_invoice_cancel_service.dart';
import 'package:pranomiapp/services/EInvoiceService/e_invoice_open_as_pdf_service.dart';
import 'package:pranomiapp/services/EInvoiceService/e_invoice_service.dart';
import 'package:pranomiapp/services/InvoiceServices/invoice_cancellation_reversal_service.dart';
import 'package:pranomiapp/services/InvoiceServices/invoice_cancelled_service.dart';
import 'package:pranomiapp/services/InvoiceServices/invoice_claim_service.dart';
import 'package:pranomiapp/services/InvoiceServices/invoice_details_service.dart';
import 'package:pranomiapp/services/InvoiceServices/invoice_service.dart';
import 'package:pranomiapp/services/InvoiceServices/send_e_invoice_service.dart';
import 'package:pranomiapp/features/products/data/product_stock_update_service.dart';

import '../../features/announcement/data/announcement_service.dart';
import '../../features/products/data/product_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<CustomerDetailService>(
    () => CustomerDetailService(),
  );

  locator.registerLazySingleton<CustomerEditService>(
    () => CustomerEditService(),
  );

  locator.registerLazySingleton<CustomerAddService>(() => CustomerAddService());

  locator.registerLazySingleton<EmployeeAddService>(() => EmployeeAddService());

  locator.registerLazySingleton<LoginServices>(() => LoginServices());

  locator.registerLazySingleton<CustomerService>(() => CustomerService());

  locator.registerLazySingleton<EmployeesService>(() => EmployeesService());

  locator.registerLazySingleton<InvoiceClaimService>(
    () => InvoiceClaimService(),
  );

  locator.registerLazySingleton<InvoiceService>(() => InvoiceService());

  locator.registerLazySingleton<SendEInvoiceService>(
    () => SendEInvoiceService(),
  );

  locator.registerLazySingleton<InvoiceDetailsService>(
    () => InvoiceDetailsService(),
  );

  locator.registerLazySingleton<InvoiceCancelService>(
    () => InvoiceCancelService(),
  );

  locator.registerLazySingleton<InvoiceCancellationReversalService>(
    () => InvoiceCancellationReversalService(),
  );

  locator.registerLazySingleton<EInvoiceService>(() => EInvoiceService());

  locator.registerLazySingleton<EInvoiceOpenAsPdfService>(
    () => EInvoiceOpenAsPdfService(),
  );

  locator.registerLazySingleton<EInvoiceCancelService>(
    () => EInvoiceCancelService(),
  );

  locator.registerLazySingleton<ProductStockUpdateService>(
    () => ProductStockUpdateService(),
  );

  locator.registerLazySingleton<ProductService>(() => ProductService());

  locator.registerLazySingleton<AccountService>(() => AccountService());

  locator.registerLazySingleton<AnnouncementService>(
    () => AnnouncementService(),
  );

  locator.registerLazySingleton<CreditService>(() => CreditService());

  locator.registerLazySingleton<NotificationsService>(
    () => NotificationsService(),
  );

  locator.registerLazySingleton<DashboardService>(
        () => DashboardService(),
  );
}
