import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/onesignal_service.dart';
import '../login_model.dart';
import 'auth_result.dart';
import 'auth_strategy.dart';

class DirectLoginStrategy implements AuthenticationStrategy {
  @override
  String get strategyName => 'DirectLoginStrategy';

  @override
  Future<AuthenticationResult> authenticate({
    required LoginResponse response,
    required String username,
    required String password,
  }) async {
    try {
      if (response.item?.apiInfo == null) {
        return AuthenticationResult(
          success: false,
          errorMessage: "Giriş bilgileri eksik. Lütfen tekrar deneyin.",
          nextAction: AuthenticationAction.none,
        );
      }

      final apiInfo = response.item!.apiInfo!;
      final prefs = locator<SharedPreferences>();
      await prefs.setString('apiKey', apiInfo.apiKey);
      await prefs.setString('apiSecret', apiInfo.apiSecret);
      await prefs.setString('subscriptionType', apiInfo.subscriptionType.name);
      await prefs.setBool('isEInvoiceActive', apiInfo.isEInvoiceActive);

      // Login to OneSignal with userId
      await OneSignalService.login(response.item!.userId);

      return AuthenticationResult(
        success: true,
        successMessage: "Giriş Başarılı",
        nextAction: AuthenticationAction.navigateToHome,
      );
    } catch (e) {
      return AuthenticationResult(
        success: false,
        errorMessage: "Bir hata oluştu: ${e.toString()}",
        nextAction: AuthenticationAction.none,
      );
    }
  }
}
