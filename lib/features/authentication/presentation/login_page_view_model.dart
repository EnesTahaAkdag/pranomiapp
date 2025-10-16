import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/features/authentication/data/login_services.dart';
import 'package:pranomiapp/Models/AuthenticationModels/login_model.dart';
import 'package:pranomiapp/core/di/injection.dart';

class LoginPageViewModel extends ChangeNotifier {
  final LoginServices _loginServices = locator<LoginServices>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  String? _warningMessage;
  String? get warningMessage => _warningMessage;

  bool _loginSuccessful = false;
  bool get loginSuccessful => _loginSuccessful;

  // SMS Verification data
  bool _requiresSmsVerification = false;
  bool get requiresSmsVerification => _requiresSmsVerification;

  // Two-Factor Authentication data
  bool _requiresTwoFactorAuth = false;
  bool get requiresTwoFactorAuth => _requiresTwoFactorAuth;

  bool _hasActive2FA = false;
  bool get hasActive2FA => _hasActive2FA;

  int? _userId;
  int? get userId => _userId;

  String? _gsmNumber;
  String? get gsmNumber => _gsmNumber;

  Future<void> login() async {
    if (_isLoading) return;

    _isLoading = true;
    _loginSuccessful = false;
    _requiresSmsVerification = false;
    _requiresTwoFactorAuth = false;
    _hasActive2FA = false;
    _errorMessage = null;
    _successMessage = null;
    _warningMessage = null;
    notifyListeners();

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    try {
      final response = await _loginServices.login(username, password);

      if (response != null) {
        _successMessage = response.successMessages.isNotEmpty ? response.successMessages.join('\n') : null;
        _warningMessage = response.warningMessages.isNotEmpty ? response.warningMessages.join('\n') : null;
        _errorMessage = response.errorMessages.isNotEmpty ? response.errorMessages.join('\n') : null;

        if (response.success && response.item != null) {
          final item = response.item!;

          // Store user data for potential verification steps
          _userId = item.userId;
          _gsmNumber = item.gsmNumber;
          _hasActive2FA = item.hasActive2FA;

          // Navigation logic:
          // 1. If requireSms is false -> direct login (ignore hasActive2FA)
          // 2. If requireSms is true AND hasActive2FA is false -> SMS verification only
          // 3. If requireSms is true AND hasActive2FA is true -> Two-factor auth

          if (!item.requireSms) {
            // Direct login without any verification
            if (item.apiInfo != null) {
              final apiInfo = item.apiInfo!;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('apiKey', apiInfo.apiKey);
              await prefs.setString('apiSecret', apiInfo.apiSecret);
              await prefs.setString('subscriptionType', apiInfo.subscriptionType.name);
              await prefs.setBool('isEInvoiceActive', apiInfo.isEInvoiceActive);
              _loginSuccessful = true;
              if (_successMessage == null && _errorMessage == null && _warningMessage == null) {
                _successMessage = "Giriş Başarılı";
              }
            } else {
              _errorMessage = "Giriş bilgileri eksik. Lütfen tekrar deneyin.";
            }
          } else {
            // requireSms is true - check for 2FA
            if (item.hasActive2FA) {
              // Navigate to Two-Factor Authentication
              _requiresTwoFactorAuth = true;
              _successMessage = "İki faktörlü doğrulama gerekiyor";
            } else {
              // Navigate to SMS Verification only
              _requiresSmsVerification = true;
              _successMessage = "SMS doğrulaması gerekiyor";
            }
          }
        } else {
          if (_errorMessage == null && _successMessage == null && _warningMessage == null) {
            _errorMessage = "Giriş bilgileri hatalı veya bir sorun oluştu.";
          }
        }
      } else {
        _errorMessage = "Giriş isteği başarısız oldu. Lütfen internet bağlantınızı kontrol edin.";
      }
    } catch (e) {
      _errorMessage = "Bir hata oluştu: ${e.toString()}";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the verification flags after navigation
  void resetVerificationFlags() {
    _requiresSmsVerification = false;
    _requiresTwoFactorAuth = false;
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _warningMessage = null;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
