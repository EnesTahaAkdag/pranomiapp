import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:pranomiapp/Helper/ApiServices/api_service.dart';
import 'package:pranomiapp/features/sms_verification/data/sms_verification_model.dart';

class SmsVerificationService extends ApiServiceBase {
  Future<SmsVerificationResponse?> loginWithSmsVerification(String smsCode,
      int userId, String gsmNumber) async {
    try {
      final response = await dio.post(
        '/SmsVerificationForLogin',
        data: {'SmsCode': smsCode, 'UserId': userId, 'GsmNumber': gsmNumber},
      );
          return SmsVerificationResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint("Dio error: ${e.message}");
      return null;
    } catch (e) {
      debugPrint("Unexpected error: $e");
      return null;
    }
  }
}