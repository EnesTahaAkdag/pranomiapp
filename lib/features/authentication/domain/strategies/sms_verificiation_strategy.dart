import '../../../../Models/AuthenticationModels/login_model.dart';
import 'auth_result.dart';
import 'auth_strategy.dart';

class SmsVerificationStrategy implements AuthenticationStrategy {
  @override
  String get strategyName => 'SmsVerificationStrategy';

  @override
  Future<AuthenticationResult> authenticate({
    required LoginResponse response,
    required String username,
    required String password,
  }) async {
    final item = response.item;

    if (item == null || item.userId == null || item.gsmNumber == null) {
      return AuthenticationResult(
        success: false,
        errorMessage: "Kullanıcı bilgileri eksik.",
        nextAction: AuthenticationAction.none,
      );
    }

    return AuthenticationResult(
      success: true,
      successMessage: "SMS doğrulaması gerekiyor",
      nextAction: AuthenticationAction.navigateToSmsVerification,
      data: {
        'userId': item.userId,
        'gsmNumber': item.gsmNumber,
      },
    );
  }
}