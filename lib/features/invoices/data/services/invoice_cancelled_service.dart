import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../core/services/api_service_base.dart';
import '../models/invoice_cancel_model.dart';

class InvoiceCancelService extends ApiServiceBase {
  Future<String?> invoiceCancel(InvoiceCancelModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Invoice/CancelInvoice',
        data: model.toJson(),
        options: Options(headers: headers),
      );
      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final jsonMap = Map<String, dynamic>.from(response.data);
        final resp = InvoiceCancelResponseModel.fromJson(jsonMap);

        if (resp.success) {
          return resp.item;
        } else {
          debugPrint('İşlem başarısız. Errors: ${resp.errorMessages}');
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
      debugPrint('Beklenmeyen Hata: $e');
      return null;
    }
  }
}
