import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pranomiapp/Helper/ApiServices/ApiService.dart';
import 'package:pranomiapp/Models/AuthenticationModels/loginmodel.dart';

class LoginServices extends ApiServiceBase {
  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await dio.post(
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
