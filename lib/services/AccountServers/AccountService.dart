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

      String path;
      if (search != null && search.isNotEmpty) {
        path = '/Account/$search'; // MODIFIED: Search term becomes part of the path
      } else {
        path = '/Account';
      }

      // MODIFIED: 'search' is removed from queryParameters as it's now in the path
      Map<String, dynamic> queryParameters = {
        'page': page,
        'size': size,
      };

      final response = await dio.get(
        path, // Uses the dynamically constructed path
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return AccountResponseModel.fromJson(response.data);
      } else {
        debugPrint("Veri alınamadı (fetchAccounts): ${response.statusCode}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint(
        'DioException (fetchAccounts): ${dioError.response?.data ?? dioError.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Genel Hata (fetchAccounts): $e');
      return null;
    }
  }
}
