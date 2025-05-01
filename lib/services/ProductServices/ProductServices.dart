import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:pranomiapp/Models/ProductsModels/productmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductServices {
  final Dio _dio = Dio();

  Future<List<ProductResponseModel>> fetchProducts({
    String? query,
    int size = 20,
    int page = 0,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('apiKey');
    final apiSecret = prefs.getString('apiSecret');

    if (apiKey == null || apiSecret == null) {
      throw Exception("API key veya secret bulunamadı");
    }

    final String basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    late String url;
    if (query != null && query.isNotEmpty) {
      url = "https://apitest.pranomi.com/Product/$query?size=$size&page=$page";
    } else {
      url = "https://apitest.pranomi.com/Product?page=$page&size=$size";
    }

    try {
      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            'apiKey': apiKey,
            'apiSecret': apiSecret,
            'authorization': basicAuth,
          },
        ),
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
