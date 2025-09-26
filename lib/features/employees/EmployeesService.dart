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
  }) async {
    try {
      final headers = await getAuthHeaders();

      String path;
      if (search != null && search.isNotEmpty) {
        path = '/Customer/$search'; // Use search term in the path
      } else {
        path = '/Customer';
      }

      // Query parameters that are always sent
      Map<String, dynamic> queryParameters = {
        'page': page,
        'size': size,
        'customerType': customerType.name,
      };

      final response = await dio.get(
        path, // Use the dynamically constructed path
        queryParameters: queryParameters, // Pass the consistent query parameters
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return EmployeesResponse.fromJson(response.data);
      } else {
        debugPrint("Veri alınamadı (fetchEmployees): ${response.statusCode}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint(
        'DioException (fetchEmployees): ${dioError.response?.data ?? dioError.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Genel Hata (fetchEmployees): $e');
      return null;
    }
  }
}
