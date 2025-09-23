import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancelModel.dart';

import '../../features/e_invoice/domain/EInvoiceCancelModel.dart';

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
