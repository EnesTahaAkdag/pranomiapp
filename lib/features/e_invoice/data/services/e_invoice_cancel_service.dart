import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/api_service_base.dart';
import '../../../invoices/data/models/invoice_cancel_model.dart';
import '../../domain/e_invoice_cancel_model.dart';

class EInvoiceCancelService extends ApiServiceBase {
  Future<String?> invoiceCancel(EInvoiceCancelModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/EInvoice/CancelEInvoice',
        data: model.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200 && response.data != null) {
        final jsonMap = Map<String, dynamic>.from(response.data);
        final resp = InvoiceCancelResponseModel.fromJson(jsonMap);
        return resp.success ? resp.item : null;
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
