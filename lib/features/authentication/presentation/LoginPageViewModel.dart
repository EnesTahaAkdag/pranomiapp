import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pranomiapp/features/authentication/data/LoginServices.dart';
import 'package:pranomiapp/Models/AuthenticationModels/LoginModel.dart';
import 'package:pranomiapp/core/di/Injection.dart';

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

  Future<void> login() async {
    if (_isLoading) return;

    _isLoading = true;
    _loginSuccessful = false;
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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('apiKey', item.apiKey);
          await prefs.setString('apiSecret', item.apiSecret);
          await prefs.setString('subscriptionType', item.subscriptionType.name);
          await prefs.setBool('isEInvoiceActive', item.isEInvoiceActive);
          _loginSuccessful = true;
          if (_successMessage == null && _errorMessage == null && _warningMessage == null) {
            _successMessage = "Giriş Başarılı"; // Default success message
          }
        } else {
          if (_errorMessage == null && _successMessage == null && _warningMessage == null) {
            _errorMessage = "Giriş bilgileri hatalı veya bir sorun oluştu."; // Default error
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
