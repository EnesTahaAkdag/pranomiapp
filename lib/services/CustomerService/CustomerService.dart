import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerModel.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';

class CustomerService extends ApiServiceBase {
  Future<CustomerResponseModel?> fetchCustomers({
    required int page,
    required int size,
    required CustomerTypeEnum customerType,
    String? search,
  }) async {
    try {
      final headers = await getAuthHeaders();

      final response = await dio.get(
        '/Customer',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return CustomerResponseModel.fromJson(response.data);
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
