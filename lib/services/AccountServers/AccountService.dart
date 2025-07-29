import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/AccountModels/AccountModels.dart';

class AccountService extends ApiServiceBase {
  Future<AccountResponseModel?> fetchAccounts({
    required int page,
    required int size,
    String? search,
  }) async {
    try {
      final headers = await getAuthHeaders();

      final response = await dio.get(
        '/Account',
        queryParameters: {
          'page': page,
          'size': size,
          if (search != null) 'search': search,
        },
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return AccountResponseModel.fromJson(response.data);
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
