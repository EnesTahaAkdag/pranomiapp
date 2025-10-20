import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/features/authentication/domain/strategies/auth_result.dart';

import 'login_page_view_model.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginPageViewModel _viewModel;
  late bool _isPasswordVisible;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginPageViewModel(); // Initialize the ViewModel
    _viewModel.addListener(_onViewModelChanged);
    _isPasswordVisible = false;
  }

  void _onViewModelChanged() async {
    if (!mounted) return;

    final authResult = _viewModel.authResult;
    if (authResult == null) {
      setState(() {}); // Rebuild for loading state changes
      return;
    }

    // Show messages
    if (authResult.errorMessage != null) {
      _showMessage(authResult.errorMessage!, AppTheme.errorColor);
      _viewModel.clearMessages();
    } else if (authResult.warningMessage != null) {
      _showMessage(authResult.warningMessage!, AppTheme.warningColor);
      _viewModel.clearMessages();
    } else if (authResult.successMessage != null &&
        authResult.nextAction != AuthenticationAction.navigateToHome) {
      // Show success message if not navigating to home immediately
      _showMessage(authResult.successMessage!, AppTheme.successColor);
      _viewModel.clearMessages();
    }

    // Handle navigation based on AuthenticationAction from Strategy Pattern
    if (authResult.nextAction != null) {
      await _handleAuthenticationAction(authResult);
    }

    // Update loading state
    setState(() {});
  }

  Future<void> _handleAuthenticationAction(
    AuthenticationResult authResult,
  ) async {
    if (!mounted) return;

    switch (authResult.nextAction!) {
      case AuthenticationAction.navigateToHome:
        debugPrint("DirectLoginStrategy: Navigating to home");
        _viewModel.resetVerificationFlags();
        context.go('/');
        break;

      case AuthenticationAction.navigateToSmsVerification:
        debugPrint("SmsVerificationStrategy: Navigating to SMS verification");
        final userId = authResult.data?['userId'] as int?;
        final gsmNumber = authResult.data?['gsmNumber'] as String?;

        if (userId != null && gsmNumber != null) {
          _viewModel.resetVerificationFlags();
          final result = await context.push(
            '/sms-verification',
            extra: {'userId': userId, 'gsmNumber': gsmNumber},
          );

          if (result == 'success' && mounted) {
            context.go('/');
          }
        } else {
          _showMessage(
            'SMS doğrulama bilgileri eksik',
            AppTheme.errorColor,
          );
        }
        break;

      case AuthenticationAction.navigateToTwoFactorAuth:
        debugPrint("TwoFactorAuthStrategy: Navigating to 2FA");
        final userId = authResult.data?['userId'] as int?;
        final gsmNumber = authResult.data?['gsmNumber'] as String?;

        if (userId != null && gsmNumber != null) {
          _viewModel.resetVerificationFlags();
          final result = await context.push(
            '/two-factor-auth',
            extra: {'userId': userId, 'gsmNumber': gsmNumber},
          );

          if (result == 'success' && mounted) {
            context.go('/');
          }
        } else {
          _showMessage(
            '2FA doğrulama bilgileri eksik',
            AppTheme.errorColor,
          );
        }
        break;

      case AuthenticationAction.none:
        // No navigation action required
        debugPrint("No navigation action required");
        break;
    }
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose(); // Dispose the ViewModel
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.transparent,
      body: Stack(
        children: [
          _buildLoginForm(),
          if (_viewModel.isLoading) // Use ViewModel's isLoading
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.blackOverlay70,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.blackOverlay30,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 48,
                      width: 48,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.white,
                        ),
                        strokeWidth: 5,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Giriş yapılıyor...",
                      style: TextStyle(
                        color: AppTheme.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            children: [
              Image.asset('lib/assets/images/PranomiLogo.png', height: 100),
              const SizedBox(height: 48),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.blackOverlay30,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _icon(),
                      const SizedBox(height: 32),
                      _inputField(
                        Icons.person_outline,
                        "Kullanıcı Adı",
                        _viewModel.usernameController,
                        isPassword: false,
                      ),
                      const SizedBox(height: 16),
                      _inputField(
                        Icons.lock_outline,
                        "Şifre",
                        _viewModel.passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: 24),
                      _loginBtn(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _icon() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.white, width: 2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock, color: Color(0xFFFFFFFF), size: 48),
    );
  }

  Widget _inputField(
    IconData icon,
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable:
          isPassword ? controller : ValueNotifier(controller.value),
      builder: (context, value, child) {
        return TextField(
          cursorColor: Colors.orange,
          controller: controller,
          obscureText: isPassword ? !_isPasswordVisible : false,
          style: const TextStyle(color: AppTheme.white),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.white),
            hintText: hintText,
            hintStyle: const TextStyle(color: AppTheme.textWhite70),
            filled: true,
            fillColor: AppTheme.whiteOverlay10,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.textWhite70),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppTheme.white),
            ),
            suffixIcon:
                isPassword
                    ? Opacity(
                      opacity: _calculateOpacity(value.text.length),
                      child: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xffffffff),
                        ),
                        onPressed:
                            () => setState(
                              () => _isPasswordVisible = !_isPasswordVisible,
                            ),
                      ),
                    )
                    : null,
          ),
        );
      },
    );
  }

  double _calculateOpacity(int length) {
    if (length >= 7) {
      return 1.0;
    } else {
      return 0.3 + (length * 0.1);
    }
  }

  Widget _loginBtn() {
    return ElevatedButton(
      onPressed:
          _viewModel.isLoading
              ? null
              : () async {
                // Use ViewModel's isLoading and call ViewModel's login
                // Clear previous messages before attempting a new login
                _viewModel.clearMessages();
                await _viewModel.login();
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Giriş Yap",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showMessage(String message, Color backgroundColor) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
