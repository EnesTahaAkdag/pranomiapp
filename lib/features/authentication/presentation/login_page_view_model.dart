import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/features/authentication/data/login_services.dart';
import '../domain/login_model.dart';
import 'package:pranomiapp/core/di/injection.dart';

import '../domain/strategies/auth_result.dart';
import '../domain/strategies/auth_strategy_selector.dart';

class LoginPageViewModel extends ChangeNotifier {
  final LoginServices _loginServices = locator<LoginServices>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  AuthenticationResult? _authResult;

  AuthenticationResult? get authResult => _authResult;

  // Helper getters for backward compatibility
  String? get errorMessage => _authResult?.errorMessage;

  String? get successMessage => _authResult?.successMessage;

  String? get warningMessage => _authResult?.warningMessage;

  bool get loginSuccessful =>
      _authResult?.nextAction == AuthenticationAction.navigateToHome;

  bool get requiresSmsVerification =>
      _authResult?.nextAction == AuthenticationAction.navigateToSmsVerification;

  bool get requiresTwoFactorAuth =>
      _authResult?.nextAction == AuthenticationAction.navigateToTwoFactorAuth;

  int? get userId => _authResult?.data?['userId'] as int?;

  String? get gsmNumber => _authResult?.data?['gsmNumber'] as String?;

  Future<void> login() async {
    if (_isLoading) return;

    _isLoading = true;
    _authResult = null;
    notifyListeners();

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await _loginServices.login(username, password);

      if (response != null) {
        if (response.success && response.item != null) {
          // Strategy Pattern kullanarak authentication işlemi
          final strategy = AuthenticationStrategySelector.selectStrategy(
            response,
          );

          debugPrint("Using authentication strategy: ${strategy.strategyName}");

          _authResult = await strategy.authenticate(
            response: response,
            username: username,
            password: password,
          );

          // Response'daki mesajları da ekle
          if (response.successMessages.isNotEmpty) {
            _authResult = AuthenticationResult(
              success: _authResult!.success,
              successMessage:
                  _authResult!.successMessage ??
                  response.successMessages.join('\n'),
              errorMessage: _authResult!.errorMessage,
              warningMessage:
                  response.warningMessages.isNotEmpty
                      ? response.warningMessages.join('\n')
                      : _authResult!.warningMessage,
              nextAction: _authResult!.nextAction,
              data: _authResult!.data,
            );
          }
        } else {
          _authResult = AuthenticationResult(
            success: false,
            errorMessage:
                response.errorMessages.isNotEmpty
                    ? response.errorMessages.join('\n')
                    : "Giriş bilgileri hatalı veya bir sorun oluştu.",
            nextAction: AuthenticationAction.none,
          );
        }
      } else {
        _authResult = AuthenticationResult(
          success: false,
          errorMessage:
              "Giriş isteği başarısız oldu. Lütfen internet bağlantınızı kontrol edin.",
          nextAction: AuthenticationAction.none,
        );
      }
    } catch (e) {
      _authResult = AuthenticationResult(
        success: false,
        errorMessage: "Bir hata oluştu: ${e.toString()}",
        nextAction: AuthenticationAction.none,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetVerificationFlags() {
    _authResult = null;
  }

  void clearMessages() {
    _authResult = null;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
