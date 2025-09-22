import 'package:get_it/get_it.dart';
import 'package:pranomiapp/features/authentication/data/LoginServices.dart';
import 'package:pranomiapp/services/CustomerService/CustomerAddService.dart';
import 'package:pranomiapp/services/CustomerService/CustomerDetailService.dart';
import 'package:pranomiapp/services/CustomerService/CustomerEditService.dart';
import 'package:pranomiapp/services/CustomerService/CustomerService.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceCancelService.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceOpenAsPdfService.dart';
import 'package:pranomiapp/services/EInvoiceService/EInvoiceService.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancellationReversalService.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceCancelledService.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceClaimService.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceDetailsService.dart';
import 'package:pranomiapp/services/InvoiceServices/InvoiceService.dart';
import 'package:pranomiapp/services/InvoiceServices/SendEInvoiceService.dart';
import 'package:pranomiapp/services/ProductServices/ProductStockUpdateService.dart';

import '../../services/ProductServices/ProductService.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton<CustomerDetailService>(
    () => CustomerDetailService(),
  );

  locator.registerLazySingleton<CustomerEditService>(
    () => CustomerEditService(),
  );

  locator.registerLazySingleton<CustomerAddService>(() => CustomerAddService());

  locator.registerLazySingleton<LoginServices>(() => LoginServices());

  locator.registerLazySingleton<CustomerService>(() => CustomerService());

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

  locator.registerLazySingleton<ProductService>(
    () => ProductService(),
  );
}
