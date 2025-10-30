import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/services/api_service_base.dart';
import '../domain/product_stock_update_model.dart';

/// This class is responsible for updating product stock.

class ProductStockUpdateService extends ApiServiceBase {
  Future<int?> updateStock(ProductStockUpdateModel model) async {
    try {
      final headers = await getAuthHeaders();
      final response = await dio.put(
        '/Product/UpdateStock',
        data: model.toJson(),
        options: Options(headers: headers),
      );

      debugPrint('Response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final jsonMap = Map<String, dynamic>.from(response.data);
        final resp = StockUpdateResponseModel.fromJson(jsonMap);

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
      debugPrint('Stok güncelleme hatası: $e');
      return null;
    }
  }
}
