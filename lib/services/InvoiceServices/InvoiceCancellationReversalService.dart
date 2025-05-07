import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancellationReversalModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InvoiceCancellationReversalService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<String?> invoiceCancel(InvoiceCancellationReversalModel model) async {
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
        '/Invoice/UnCancelInvoice',
        data: model.toJson(),
        options: Options(
          headers: {
            'ApiKey': apiKey,
            'ApiSecret': apiSecret,
            'Authorization': basicAuth,
          },
        ),
      );
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestBody: true,
          responseBody: true,
          error: true,
        ),
      );

      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final jsonMap = Map<String, dynamic>.from(response.data);
        final resp = InvoiceCancellationReversalResponseModel.fromJson(jsonMap);
        if (resp.success) {
          return resp.item;
        } else {
          debugPrint(
            'Sunucu döndürdü ama Success=false. Errors: ${resp.errorMessages}',
          );
          return null;
        }
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('Fatura iptal geri alma hatası: $e');
      return null;
    }
  }
}
