import 'package:get_it/get_it.dart';
import 'package:pranomiapp/services/AuthenticationService/LoginServices.dart';
import 'package:pranomiapp/services/CustomerService/CustomerDetailService.dart';
import 'package:pranomiapp/services/CustomerService/CustomerEditService.dart';


final GetIt locator = GetIt.instance;

void setupLocator() {

  locator.registerLazySingleton<CustomerDetailService>(() => CustomerDetailService());

  locator.registerLazySingleton<CustomerEditService>(() => CustomerEditService());

  locator.registerLazySingleton<LoginServices>(() => LoginServices());
}
