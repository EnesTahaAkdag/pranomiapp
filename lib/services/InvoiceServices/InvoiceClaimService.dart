import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceClaimModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceClaimService {
  final Dio _dio = Dio();

  Future<InvoiceClaimResponseModel> fetchInvoiceClaim({
    required int page,
    required int size,
    required int invoiceType,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    if (apiKey == null || apiSecret == null) {
      throw Exception("API key veya secret bulunamadı");
    }

    final String basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    final String url =
        "https://apitest.pranomi.com/Claim?size=$size&page=$page&invoiceType=$invoiceType";

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'apiKey': apiKey,
            'apiSecret': apiSecret,
            'authorization': basicAuth,
          },
        ),
      );

      if (response.statusCode == 200) {
        return InvoiceClaimResponseModel.fromJson(response.data);
      } else {
        throw Exception("Fatura verisi alınamadı: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio hatası: ${e.message}");
    } catch (e) {
      throw Exception("Beklenmeyen hata: $e");
    }
  }
}
