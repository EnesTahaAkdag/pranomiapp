// lib/services/InvoiceServices/InvoiceDetailsService.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceDetailsModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceDetailsService {
  final Dio _dio = Dio();

  Future<InvoiceDetailsResponseModel> fetchInvoiceDetails({
    required int invoiceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    if (apiKey == null || apiSecret == null) {
      throw Exception("API Key veya Secret Bulunamadı");
    }

    final String basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';
    final String url = "https://apitest.pranomi.com/Invoice/Detail/$invoiceId";

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
        return InvoiceDetailsResponseModel.fromJson(response.data);
      } else {
        throw Exception("Fatura Detayları Gelmedi: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio Hatası: ${e.message}");
    } catch (e) {
      throw Exception("Beklenmeyen hata: $e");
    }
  }
}
