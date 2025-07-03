import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helpers/Methods/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceCancellationReversalModel.dart';

class InvoiceCancellationReversalService extends ApiServiceBase {
  Future<String?> invoiceCancel(InvoiceCancellationReversalModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Invoice/UnCancelInvoice',
        data: model.toJson(),
        options: Options(headers: headers),
      );

      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final jsonMap = Map<String, dynamic>.from(response.data);
        final resp = InvoiceCancellationReversalResponseModel.fromJson(jsonMap);
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
      debugPrint('Fatura iptal geri alma hatası: $e');
      return null;
    }
  }
}
