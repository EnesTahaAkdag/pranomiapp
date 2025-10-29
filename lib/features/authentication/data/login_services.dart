import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/api_service_base.dart';
import '../domain/login_model.dart';

class LoginServices extends ApiServiceBase {
  Future<LoginResponse?>  login(String username, String password) async {
    try {
      final response = await dio.post(
        'Login',
        data: {'username': username, 'password': password},
      );

      debugPrint("Dio Response JSON: ${response.data}");
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401){
        throw Exception("Kullanıcı adı veya şifre hatalı.");
      }
      debugPrint("Dio error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return null;
    }
  }
}
