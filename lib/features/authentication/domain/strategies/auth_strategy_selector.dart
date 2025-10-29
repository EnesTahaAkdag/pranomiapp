import 'package:pranomiapp/features/authentication/domain/strategies/sms_verificiation_strategy.dart';
import 'package:pranomiapp/features/authentication/domain/strategies/two_factor_auth_strategy.dart';

import '../login_model.dart';
import 'auth_strategy.dart';
import 'direct_login_strategy.dart';

class AuthenticationStrategySelector {
  static AuthenticationStrategy selectStrategy(LoginResponse response) {
    final item = response.item;

    if (item == null) {
      throw Exception("Login response item is null");
    }

    // Strategy seçim mantığı
    if (!item.requireSms) {
      // Direct login
      return DirectLoginStrategy();
    } else if (item.hasActive2FA) {
      // Two-factor authentication
      return TwoFactorAuthStrategy();
    } else {
      // SMS verification
      return SmsVerificationStrategy();
    }
  }
}