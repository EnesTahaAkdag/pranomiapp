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

  int? _userId;
  int? get userId => _userId;

  String? _gsmNumber;
  String? get gsmNumber => _gsmNumber;

  Future<void> login() async {
    if (_isLoading) return;

    _isLoading = true;
    _loginSuccessful = false;
    _requiresSmsVerification = false;
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

          // Check if SMS verification is required
          if (item.requireSms) {
            _requiresSmsVerification = true;
            _userId = item.userId;
            _gsmNumber = item.gsmNumber;
            _successMessage = "SMS doğrulaması gerekiyor";
          } else if (item.apiInfo != null) {
            // Direct login without SMS verification
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

  /// Resets the SMS verification flags after navigation
  void resetSmsVerificationFlags() {
    _requiresSmsVerification = false;
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
