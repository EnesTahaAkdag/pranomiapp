import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/api_service_base.dart';
import '../models/account_add_model.dart';

class AccountAddServices extends ApiServiceBase {
  Future<AccountAddResponseModel?> addPayment(AccountAddModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Account/AddPayment',
        data: model.toJson(),
        options: Options(headers: headers),
      );

      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        return AccountAddResponseModel.fromJson(response.data);
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
