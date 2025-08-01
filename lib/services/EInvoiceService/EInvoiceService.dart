import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/EInvoiceModels/EInvocieModel.dart';

class EInvoiceService extends ApiServiceBase {
  Future<EInvoiceResponseModel?> fetchEInvoices({
    required int page,
    required int size,
    required String eInvoiceType,
    required DateTime? eInvoiceDate,
    required String recordType,
    String? search,
  }) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        "?size=$size&page=$page"
        "&invoiceType=$eInvoiceType"
        "${eInvoiceDate != null ? '&invoiceDate=${eInvoiceDate.toIso8601String().split('T')[0]}' : ''}"
        "&recordType=$recordType",
        options: Options(headers: headers),
      );
      if (response.statusCode == 200) {
        return EInvoiceResponseModel.fromJson(response.data);
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
