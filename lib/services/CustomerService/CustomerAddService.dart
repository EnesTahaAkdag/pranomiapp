import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerAddModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerAddService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<bool> addCustomer(CustomerAddModel model) async {
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
        '/Customer/Customer/Add',
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
        return true;
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
        return false;
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return false;
    }
  }
}
