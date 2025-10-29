import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/api_service_base.dart';
import '../models/customer_edit_model.dart';

class CustomerEditService extends ApiServiceBase {
  Future<CustomerResponseModel?> editCustomer(CustomerEditModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Customer/Customer/Edit',
        data: model.toJson(),
        options: Options(headers: headers),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        return CustomerResponseModel.fromJson(response.data);
      } else {
        return null;
      }
    } catch (e, st) {
      debugPrint('🚨 Edit Error: $e');
      debugPrint('$st');
      return null;
    }
  }
}
