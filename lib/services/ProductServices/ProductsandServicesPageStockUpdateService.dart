import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/Models/ProductsModels/productstockupdatemodel.dart';

class ProductsandServicesPageStockUpdateService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<int?> updateStock(ProductStockUpdateModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');
    if (apiKey == null || apiSecret == null) {
      throw Exception('API anahtarları bulunamadı.');
    }
    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    try {
      final response = await _dio.put(
        '/Product/UpdateStock',
        data: model.toJson(),
        options: Options(
          headers: {
            'ApiKey': apiKey,
            'ApiSecret': apiSecret,
            'Authorization': basicAuth,
          },
        ),
      );

      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final jsonMap = Map<String, dynamic>.from(response.data);
        final resp = StockUpdateResponseModel.fromJson(jsonMap);

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
      debugPrint('Stok güncelleme hatası: $e');
      return null;
    }
  }
}
