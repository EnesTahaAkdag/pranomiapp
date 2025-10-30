import 'package:pranomiapp/features/customers/domain/customer_type_enum.dart';

import '../../../../core/services/api_service_base.dart';
import '../models/employees_model.dart';

class EmployeesService extends ApiServiceBase {
  Future<EmployeesResponse?> fetchEmployees({
    required int page,
    required int size,
    required CustomerTypeEnum customerType,
    String? search,
  }) {
    return getRequest(
      path:
          search != null && search.isNotEmpty
              ? 'Customer/Customers/$search'
              : 'Customer/Customers',
      queryParameters: {
        'page': page,
        'size': size,
        'customerType': customerType.name,
      },
      fromJson: (data) => EmployeesResponse.fromJson(data),
    );
  }
}
