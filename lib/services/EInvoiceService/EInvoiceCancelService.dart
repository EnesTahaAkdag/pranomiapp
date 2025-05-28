import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/EInvoiceModels/EInvoiceCancelModel.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancelModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EInvoiceCancelService {
  final Dio _dio;

  EInvoiceCancelService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: 'https://apitest.pranomi.com/',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Future<String?> invoiceCancel(EInvoiceCancelModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');
    if (apiKey == null || apiSecret == null) {
      throw Exception('API anahtarları bulunamadı.');
    }

    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    try {
      final response = await _dio.post(
        '/EInvoice/CancelEInvoice',
        data: model.toJson(),
        options: Options(
          headers: {
            'ApiKey': apiKey,
            'ApiSecret': apiSecret,
            'Authorization': basicAuth,
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonMap = Map<String, dynamic>.from(response.data);
        final resp = InvoiceCancelResponseModel.fromJson(jsonMap);
        return resp.success ? resp.item : null;
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('Beklenmeyen Hata: $e');
      return null;
    }
  }
}
