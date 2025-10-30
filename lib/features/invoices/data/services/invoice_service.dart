import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../../../core/services/api_service_base.dart';
import '../models/invoice_model.dart';

class InvoiceService extends ApiServiceBase {
  Future<InvoicesResponseModel?> fetchInvoice({
    required int page,
    required int size,
    required int invoiceType,
    String? search,
  }) async {
    bool hasSearch = search != null && search.trim().isNotEmpty;

    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        hasSearch
            ? "Invoice/Invoices/${Uri.encodeComponent(search)}?size=$size&page=$page&invoiceType=$invoiceType"
            : "Invoice/Invoices?size=$size&page=$page&invoiceType=$invoiceType",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return InvoicesResponseModel.fromJson(response.data);
      } else {
        throw Exception("Fatura verisi alınamadı: ${response.statusCode}");
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('Stok güncelleme hatası: $e');
      return null;
    }
  }
}
