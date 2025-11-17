import 'package:dio/dio.dart';

import '../../../../core/services/api_service_base.dart';
import '../models/employee_detail_model.dart';

class EmployeeDetailService extends ApiServiceBase {
  Future<EmployeeDetailModel?> getEmployeeDetail(int id) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        '/Customer/Detail/$id',
        options: Options(headers: headers),
      );
      if (response.statusCode == 200 && response.data['Item'] != null) {
        return EmployeeDetailModel.fromJson(response.data['Item']);
      }
    } on DioException catch (e) {
      handleError(e);
    }
    return null;
  }
}
