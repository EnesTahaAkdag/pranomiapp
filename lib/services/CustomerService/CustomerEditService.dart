import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerEditModel.dart';

class CustomerEditService extends ApiServiceBase {
  Future<bool> editCustomer(CustomerEditModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Customer/Customer/Edit',
        data: model.toJson(),
        options: Options(headers: headers),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Edit Error: $e');
      return false;
    }
  }
}
