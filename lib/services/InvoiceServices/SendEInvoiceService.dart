import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceSendEInvoiceModel.dart';

class SendEInvoiceService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<String?> sendEinvoice(SendEInvoiceModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');
    if (apiKey == null || apiSecret == null) {
      throw Exception('API anahtarları bulunamadı.');
    }

    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';
    final payload = model.toJson();
    debugPrint('Request payload: ${jsonEncode(payload)}');

    try {
      final response = await _dio.post(
        '/Invoice/SendEInvoice',
        data: payload,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': basicAuth,
          },
        ),
      );

      debugPrint('Response [${response.statusCode}]: ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final resp = SendEInvoiceResponseModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        if (resp.success) return resp.item;

        return null;
      }
      return null;
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map<String, dynamic>) {
        final resp = SendEInvoiceResponseModel.fromJson(data);
        debugPrint('API Hatası: ${resp.errorMessages}');
        return null;
      }
      debugPrint('DioError: $data');
      return null;
    } catch (e) {
      debugPrint('Beklenmeyen hata: $e');
      return null;
    }
  }

  Future<SendEInvoiceResponseModel?> sendEinvoiceFullResponse(
    SendEInvoiceModel model,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');
    if (apiKey == null || apiSecret == null) {
      throw Exception('API anahtarları bulunamadı.');
    }

    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';
    final payload = model.toJson();
    debugPrint('Request payload: ${jsonEncode(payload)}');

    try {
      final response = await _dio.post(
        '/Invoice/SendEInvoice',
        data: payload,
        options: Options(
          headers: {
            'apiKey': apiKey,
            'apiSecret': apiSecret,
            'Authorization': basicAuth,
          },
        ),
      );

      debugPrint('Response [${response.statusCode}]: ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final resp = SendEInvoiceResponseModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return resp;
      }
      return null;
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map<String, dynamic>) {
        final resp = SendEInvoiceResponseModel.fromJson(data);
        debugPrint('API Hatası: ${resp.errorMessages}');
        return resp;
      }
      debugPrint('DioError: $data');
      return null;
    } catch (e) {
      debugPrint('Beklenmeyen hata: $e');
      return null;
    }
  }
}
