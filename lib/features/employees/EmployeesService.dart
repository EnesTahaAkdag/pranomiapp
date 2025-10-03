import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:pranomiapp/features/employees/EmployeesModel.dart';

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
              ? '/Customer/$search'
              : '/Customer',
      queryParameters: {
        'page': page,
        'size': size,
        'customerType': customerType.name,
      },
      fromJson: (data) => EmployeesResponse.fromJson(data),
    );
  }
}
