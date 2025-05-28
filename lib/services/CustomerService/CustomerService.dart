import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  final Dio _dio = Dio();

  Future<CustomerResponseModel?> fetchCustomers({
    required int page,
    required int size,
    required String customerType,
    String? search,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString("apiKey");
    final apiSecret = prefs.getString("apiSecret");

    if (apiKey == null || apiSecret == null) {
      throw Exception("API Key veya Secret bulunamadı");
    }

    final String basicAuth =
        'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

    String baseUrl = "https://apitest.pranomi.com/Customer";
    if (search != null && search.isNotEmpty) {
      baseUrl += "/$search";
    }
    String url =
        "$baseUrl?size=$size&page=$page"
        "&customerType=$customerType";

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
        return CustomerResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          "Kullanıcılar Verisi Alınamadı: ${response.statusCode}",
        );
      }
    } on DioException catch (dioError) {
      debugPrint('DioError: ${dioError.response?.data ?? dioError.message}');
      return null;
    } catch (e) {
      debugPrint('!!HATA:$e');
      return null;
    }
  }
}
