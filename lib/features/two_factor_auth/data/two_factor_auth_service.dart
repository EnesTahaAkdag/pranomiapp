import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pranomiapp/Helper/ApiServices/api_service.dart';
import 'package:pranomiapp/features/two_factor_auth/data/two_factor_auth_model.dart';

class TwoFactorAuthService extends ApiServiceBase {
  Future<TwoFactorAuthResponse?> loginWithTwoFactorAuth(
    String twoFactorCode,
    int userId,
    String gsmNumber,
  ) async {
    try {
      final response = await dio.post(
        '/TwoFactorVerificationForLogin',
        data: {
          'TwoFactorCode': twoFactorCode,
          'UserId': userId,
          'GsmNumber': gsmNumber,
        },
      );
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return null;
    }
  }
}
