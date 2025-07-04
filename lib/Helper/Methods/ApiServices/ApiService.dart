import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ApiServiceBase {
  static final Dio dioInstance = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Dio get dio => ApiServiceBase.dioInstance;

  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    if (apiKey == null || apiSecret == null) {
      throw Exception('API anahtarları bulunamadı.');
    }

    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    return {
      'ApiKey': apiKey,
      'ApiSecret': apiSecret,
      'Authorization': basicAuth,
    };
  }

  void handleError(DioException e, [String? payload]) {
    if (payload != null) {
      debugPrint('DioError: ${e.response?.data ?? e.message}');
    }
  }
}
