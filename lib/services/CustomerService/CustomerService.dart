import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pranomiapp/Models/CustomerModels/CustomerModel.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerService {
  final Dio _dio;

  CustomerService([Dio? dio]) : _dio = dio ?? Dio();

  Future<CustomerResponseModel?> fetchCustomers({
    required int page,
    required int size,
    required CustomerTypeEnum customerType,
    String? search,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final apiKey = prefs.getString("apiKey");
      final apiSecret = prefs.getString("apiSecret");

      if (apiKey == null || apiSecret == null) {
        debugPrint("API Key veya Secret bulunamadı");
        return null;
      }

      final String basicAuth =
          'Basic ${base64.encode(utf8.encode('$apiKey:$apiSecret'))}';

      String url = "https://apitest.pranomi.com/Customer";
      if (search != null && search.trim().isNotEmpty) {
        url += "/${Uri.encodeComponent(search)}";
      }

      url += "?size=$size&page=$page&customerType=${customerType.name}";

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
        debugPrint("Veri alınamadı: ${response.statusCode}");
        return null;
      }
    } on DioException catch (dioError) {
      debugPrint(
        'DioException: ${dioError.response?.data ?? dioError.message}',
      );
      return null;
    } catch (e) {
      debugPrint('Genel Hata: $e');
      return null;
    }
  }
}
