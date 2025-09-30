import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/features/credit/data/CreditModel.dart';

class CreditService extends ApiServiceBase {
  Future<List<CreditTransaction>?> fetchCredits({
    required int page,
    required int size,
    DateTime? transactionDate,
  }) async {
    try {
      final headers = await getAuthHeaders();

      String path = 'EInvoice/CreditTransactions';

      Map<String, dynamic> queryParameters = {
        'page': page,
        'size': size,
        if (transactionDate != null)
          'transactiomDate': transactionDate.toIso8601String(),
      };

      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return CreditResponse.fromJson(response.data).item.creditTransactions;
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
