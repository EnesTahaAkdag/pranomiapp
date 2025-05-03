import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IncomeInvoiceService {
  final Dio _dio = Dio();

  Future<IncomeInvoiceResponseModel?> fetchIncomeInvoice({
    required int page,
    required int size,
    required int invoiceType,
    String? search,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    if (apiKey == null || apiSecret == null) {
      throw Exception("API key veya secret bulunamadı");
    }

    final String basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    // Eğer arama varsa, onu URL path içinde kullan
    String baseUrl = "https://apitest.pranomi.com/Invoice";
    if (search != null && search.isNotEmpty) {
      baseUrl += "/$search";
    }

    final String url =
        "$baseUrl?size=$size&page=$page&invoiceType=$invoiceType";

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
        return IncomeInvoiceResponseModel.fromJson(response.data);
      } else {
        throw Exception("Fatura verisi alınamadı: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('Stok güncelleme hatası: $e');
      return null;
    }
  }
}
