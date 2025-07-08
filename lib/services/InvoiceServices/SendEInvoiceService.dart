import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/InvoiceModels/InvoiceSendEInvoiceModel.dart';

class SendEInvoiceService extends ApiServiceBase {
  Future<String?> sendEinvoice(SendEInvoiceModel model) async {
    final payload = model.toJson();
    debugPrint('Request payload: ${jsonEncode(payload)}');

    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Invoice/SendEInvoice',
        data: payload,
        options: Options(headers: headers),
      );

      debugPrint('Response [${response.statusCode}]: ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final resp = SendEInvoiceResponseModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        if (resp.success) return resp.item;

        return null;
      }
      return null;
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map<String, dynamic>) {
        final resp = SendEInvoiceResponseModel.fromJson(data);
        debugPrint('API Hatası: ${resp.errorMessages}');
        return null;
      }
      debugPrint('DioError: $data');
      return null;
    } catch (e) {
      debugPrint('Beklenmeyen hata: $e');
      return null;
    }
  }

  Future<SendEInvoiceResponseModel?> sendEinvoiceFullResponse(
    SendEInvoiceModel model,
  ) async {
    final payload = model.toJson();
    debugPrint('Request payload: ${jsonEncode(payload)}');

    try {
      final headers = await getAuthHeaders();
      final response = await dio.post(
        '/Invoice/SendEInvoice',
        data: payload,
        options: Options(headers: headers),
      );

      debugPrint('Response [${response.statusCode}]: ${response.data}');
      if (response.statusCode == 200 && response.data != null) {
        final resp = SendEInvoiceResponseModel.fromJson(
          Map<String, dynamic>.from(response.data),
        );
        return resp;
      }
      return null;
    } on DioException catch (dioError) {
      final data = dioError.response?.data;
      if (data is Map<String, dynamic>) {
        final resp = SendEInvoiceResponseModel.fromJson(data);
        debugPrint('API Hatası: ${resp.errorMessages}');
        return resp;
      }
      debugPrint('DioError: $data');
      return null;
    } catch (e) {
      debugPrint('Beklenmeyen hata: $e');
      return null;
    }
  }
}
