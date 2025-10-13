import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pranomiapp/Helper/ApiServices/api_service.dart';
import 'package:pranomiapp/Models/TypeEnums/customer_type_enum.dart';
import 'package:pranomiapp/features/employees/employees_model.dart';

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
