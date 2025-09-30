// lib/features/credit/data/CreditService.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // Or foundation if only debugPrint is used
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/features/credit/data/CreditModel.dart'; // Make sure this is imported

class CreditService extends ApiServiceBase {
  Future<CreditItem?> fetchCredits({ // MODIFIED: Return CreditItem?
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
        // Ensure your API expects 'transactionDate' not 'transactiomDate'
          'transactionDate': transactionDate.toIso8601String(),
      };

      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        // MODIFIED: Return the full CreditItem object
        return CreditResponse.fromJson(response.data).item;
      } else {
        debugPrint("Veri alınamadı (fetchCredits): ${response.statusCode}");
        return null;
      }    } on DioException catch (dioError) {
      debugPrint('DioException (fetchCredits): ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('Genel Hata (fetchCredits): $e');
      return null;
    }
  }
}
