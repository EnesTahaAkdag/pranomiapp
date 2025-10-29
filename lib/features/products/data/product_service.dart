import 'package:dio/dio.dart';
import '../../../core/services/api_service_base.dart';
import '../domain/product_model.dart';

/// This class is responsible for fetching and search products from the API.

class ProductService extends ApiServiceBase {
  Future<List<ProductResponseModel>> fetchProducts({
    String? query,
    int size = 20,
    int page = 0,
  }) async {
    bool hasSearch = query != null && query.trim().isNotEmpty;

    try {
      final headers = await getAuthHeaders();
      final response = await dio.get(
        hasSearch
            ? "Product/Products/$query?size=$size&page=$page"
            : "Product/Products?page=$page&size=$size",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        final data = response.data;

        final List productsJson = data['Products'] ?? data;

        return productsJson
            .map<ProductResponseModel>(
              (json) => ProductResponseModel.fromJson(json),
            )
            .toList();
      } else {
        throw Exception("Ürün verisi alınamadı: ${response.statusCode}");
      }
    } on DioException catch (e) {
      throw Exception("Dio hatası: ${e.message}");
    } catch (e) {
      throw Exception("Beklenmeyen hata: $e");
    }
  }
}
