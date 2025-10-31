import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/injection.dart';

abstract class ApiServiceBase {
  static final Dio dioInstance = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Dio get dio => ApiServiceBase.dioInstance;

  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = locator<SharedPreferences>();
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

  Future<T?> getRequest<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) fromJson,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        return fromJson(response.data);
      } else {
        debugPrint("GET request failed: ${response.statusCode}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint('DioException: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('General Error: $e');
      return null;
    }
  }
}
