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

      final response = await dio.get(
        '/Customer',
        queryParameters: {
          'page': page,
          'size': size,
          'customerType': customerType.name,
          if (search != null) 'search': search,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return EmployeesResponse.fromJson(response.data);
      } else {
        debugPrint("Veri alınamadı: ${response.statusCode}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint(
        'DioException: ${dioError.response?.data ?? dioError.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Genel Hata: $e');
      return null;
    }
  }
}
