import '../login_model.dart';
import 'auth_result.dart';
import 'auth_strategy.dart';

class TwoFactorAuthStrategy implements AuthenticationStrategy {
  @override
  String get strategyName => 'TwoFactorAuthStrategy';

  @override
  Future<AuthenticationResult> authenticate({
    required LoginResponse response,
    required String username,
    required String password,
  }) async {
    final item = response.item;

    if (item == null) {
      return AuthenticationResult(
        success: false,
        errorMessage: "Kullanıcı bilgileri eksik.",
        nextAction: AuthenticationAction.none,
      );
    }

    return AuthenticationResult(
      success: true,
      successMessage: "İki faktörlü doğrulama gerekiyor",
      nextAction: AuthenticationAction.navigateToTwoFactorAuth,
      data: {
        'userId': item.userId,
        'gsmNumber': item.gsmNumber,
      },
    );
  }
}