import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerEditModel.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerDetailModel.dart';

class CustomerEditService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<CustomerDetailModel?> fetchCustomerDetails(int customerId) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    if (apiKey == null || apiSecret == null) return null;

    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    try {
      final response = await _dio.get(
        '/Customer/Detail/$customerId',
        options: Options(
          headers: {
            'ApiKey': apiKey,
            'ApiSecret': apiSecret,
            'Authorization': basicAuth,
          },
        ),
      );

      if (response.statusCode == 200) {
        return CustomerDetailModel.fromJson(response.data['Item']);
      }
    } on DioException catch (e) {
      debugPrint('Fetch Error: ${e.message}');
    }

    return null;
  }

  Future<bool> editCustomer(CustomerEditModel model) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    if (apiKey == null || apiSecret == null) return false;

    final basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    try {
      final response = await _dio.post(
        '/Customer/Customer/Edit',
        data: model.toJson(),
        options: Options(
          headers: {
            'ApiKey': apiKey,
            'ApiSecret': apiSecret,
            'Authorization': basicAuth,
          },
        ),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Edit Error: $e');
      return false;
    }
  }
}
