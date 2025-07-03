import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helpers/Methods/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerAddModel.dart';

class CustomerAddService extends ApiServiceBase {
  Future<bool> addCustomer(CustomerAddModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Customer/Customer/Add',
        data: model.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        return true;
      } else {
        debugPrint('Sunucu hatası: ${response.statusCode}');
        return false;
      }
    } on DioException catch (dioError) {
      debugPrint('Payload: ${jsonEncode(model.toJson())}');
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return false;
    }
  }
}
