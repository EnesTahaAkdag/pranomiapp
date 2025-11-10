import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/utils/app_constants.dart';
import 'package:pranomiapp/core/widgets/app_loading_indicator.dart';
import 'package:pranomiapp/features/authentication/domain/strategies/auth_result.dart';
import 'package:provider/provider.dart';

import 'login_page_view_model.dart';

/// Login Page - MVVM Pattern with Provider
/// Using ChangeNotifierProvider to properly manage ViewModel lifecycle
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginPageViewModel(),
      child: const _LoginView(),
    );
  }
}

/// Main view widget - Listens to ViewModel changes via Provider
class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  bool _isPasswordVisible = false;

  void _handleAuthResult(BuildContext context, LoginPageViewModel viewModel) async {
    final authResult = viewModel.authResult;
    if (authResult == null) return;

    // Show messages
    if (authResult.errorMessage != null) {
      _showMessage(authResult.errorMessage!, AppTheme.errorColor);
      viewModel.clearMessages();
    } else if (authResult.warningMessage != null) {
      _showMessage(authResult.warningMessage!, AppTheme.warningColor);
      viewModel.clearMessages();
    } else if (authResult.successMessage != null &&
        authResult.nextAction != AuthenticationAction.navigateToHome) {
      // Show success message if not navigating to home immediately
      _showMessage(authResult.successMessage!, AppTheme.successColor);
      viewModel.clearMessages();
    }

    // Handle navigation based on AuthenticationAction from Strategy Pattern
    if (authResult.nextAction != null) {
      await _handleAuthenticationAction(authResult, viewModel);
    }
  }

  Future<void> _handleAuthenticationAction(
    AuthenticationResult authResult,
    LoginPageViewModel viewModel,
  ) async {
    if (!mounted) return;

    switch (authResult.nextAction!) {
      case AuthenticationAction.navigateToHome:
        debugPrint("DirectLoginStrategy: Navigating to home");
        viewModel.resetVerificationFlags();
        context.go('/');
        break;

      case AuthenticationAction.navigateToSmsVerification:
        debugPrint("SmsVerificationStrategy: Navigating to SMS verification");
        final userId = authResult.data?['userId'] as int?;
        final gsmNumber = authResult.data?['gsmNumber'] as String?;

        if (userId != null && gsmNumber != null) {
          viewModel.resetVerificationFlags();
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
          viewModel.resetVerificationFlags();
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
  Widget build(BuildContext context) {
    return Consumer<LoginPageViewModel>(
      builder: (context, viewModel, child) {
        // Handle auth result changes
        if (viewModel.authResult != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _handleAuthResult(context, viewModel);
          });
        }

        return Scaffold(
          backgroundColor: AppTheme.transparent,
          body: Stack(
            children: [
              _buildLoginForm(viewModel),
              if (viewModel.isLoading) // Use ViewModel's isLoading
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacingL),
                    decoration: BoxDecoration(
                      color: AppTheme.blackOverlay70,
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.blackOverlay30,
                          blurRadius: AppConstants.spacing12,
                          offset: const Offset(0, AppConstants.spacingXs),
                        ),
                      ],
                    ),
                    child:  const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: AppConstants.spacing48,
                          width: AppConstants.spacing48,
                          child: AppLoadingIndicator(),
                        ),
                        SizedBox(height: AppConstants.spacingM),
                        Text(
                          "Giriş yapılıyor...",
                          style: TextStyle(
                            color: AppTheme.white,
                            fontSize: AppConstants.fontSizeL,
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
      },
    );
  }

  Widget _buildLoginForm(LoginPageViewModel viewModel) {
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
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL, vertical: AppConstants.spacing40),
          child: Column(
            children: [
              Image.asset('lib/assets/images/PranomiLogo.png', height: AppConstants.logoHeightLarge),
              const SizedBox(height: AppConstants.spacing48),
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.primaryColor, AppTheme.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.borderRadiusXl),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.blackOverlay30,
                      blurRadius: AppConstants.spacing12,
                      offset: const Offset(0, AppConstants.spacingXs),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacing28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _icon(),
                      const SizedBox(height: AppConstants.spacingXl),
                      _inputField(
                        Icons.person_outline,
                        "Kullanıcı Adı",
                        viewModel.usernameController,
                        isPassword: false,
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      _inputField(
                        Icons.lock_outline,
                        "Şifre",
                        viewModel.passwordController,
                        isPassword: true,
                      ),
                      const SizedBox(height: AppConstants.spacingL),
                      _loginBtn(viewModel),
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
      padding: const EdgeInsets.all(AppConstants.spacing12),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.white, width: AppConstants.elevationLow),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock, color: AppTheme.white, size: AppConstants.spacing48),
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
          cursorColor: AppTheme.orange,
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
              vertical: AppConstants.spacingM,
              horizontal: AppConstants.spacing20,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
              borderSide: const BorderSide(color: AppTheme.textWhite70),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusL),
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
                          color: AppTheme.white,
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

  Widget _loginBtn(LoginPageViewModel viewModel) {
    return ElevatedButton(
      onPressed:
          viewModel.isLoading
              ? null
              : () async {
                // Use ViewModel's isLoading and call ViewModel's login
                // Clear previous messages before attempting a new login
                viewModel.clearMessages();
                await viewModel.login();
              },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.accentColor,
        foregroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusL)),
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingM),
      ),
      child: const SizedBox(
        width: double.infinity,
        child: Text(
          "Giriş Yap",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: AppConstants.fontSizeXl, fontWeight: FontWeight.w600),
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
          duration: AppConstants.snackBarNormal,
        ),
      );
    }
  }
}
