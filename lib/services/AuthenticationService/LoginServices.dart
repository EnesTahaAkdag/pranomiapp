import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pranomiapp/Models/AuthenticationModels/loginmodel.dart';

class LoginServices {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://apitest.pranomi.com/',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        'Login',
        data: {'username': username, 'password': password},
      );

      debugPrint("Dio Response JSON: ${response.data}");
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return null;
    }
  }
}
