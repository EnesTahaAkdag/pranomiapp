import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/EInvoiceModels/EInvoiceOpenAsPdfModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EInvoiceOpenAsPdfService {
  final Dio _dio = Dio();

  Future<EInvoiceOpenAsPdfModel?> fetchEInvoicePdf(String uuId) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString("apiKey");
    final apiSecret = prefs.getString("apiSecret");

    if (apiKey == null || apiSecret == null) {
      throw Exception("API Key veya Secret bulunamadı");
    }

    final String basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    String url = "https://apitest.pranomi.com/EInvoice/OpenAsPdf/$uuId";

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
        return EInvoiceOpenAsPdfModel.fromJson(response.data);
      } else {
        throw Exception("E-Fatura Verisi Alınamadı: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('HATA!:$e');
      return null;
    }
  }
}
