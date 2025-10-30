import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../core/services/api_service_base.dart';
import '../../domain/e_invoice_open_as_pdf_model.dart';

class EInvoiceOpenAsPdfService extends ApiServiceBase {
  Future<EInvoiceOpenAsPdfModel?> fetchEInvoicePdf(String uuId) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        '/EInvoice/OpenAsPdf/$uuId',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return EInvoiceOpenAsPdfModel.fromJson(response.data);
      } else {
        throw Exception("E-Fatura Verisi Alınamadı: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('HATA!:$e');
      return null;
    }
  }
}
