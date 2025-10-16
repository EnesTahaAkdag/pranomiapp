import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';

// import 'package:shared_preferences/shared_preferences.dart'; // Handled by ViewModel
// import 'package:pranomiapp/services/AuthenticationService/LoginServices.dart'; // Handled by ViewModel
import 'login_page_view_model.dart'; // Import the ViewModel
// import '../../../Injection.dart'; // ViewModel handles its dependencies

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final LoginPageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = LoginPageViewModel(); // Initialize the ViewModel
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() async {
    // Handle UI updates based on ViewModel changes
    if (mounted) {
      // Show messages
      if (_viewModel.errorMessage != null) {
        _showMessage(_viewModel.errorMessage!, AppTheme.errorColor);
        _viewModel.clearMessages(); // Clear message after showing
      } else if (_viewModel.warningMessage != null) {
        _showMessage(_viewModel.warningMessage!, AppTheme.warningColor);
        _viewModel.clearMessages();
      } else if (_viewModel.successMessage != null &&
          !_viewModel.loginSuccessful) {
        // Show general success messages if not navigating immediately
        _showMessage(_viewModel.successMessage!, AppTheme.successColor);
        _viewModel.clearMessages();
      }

      // Handle navigation
      if (_viewModel.requiresTwoFactorAuth) {
        // Navigate to Two-Factor Authentication page
        debugPrint(
          "Two-Factor Authentication required, navigating to 2FA page.",
        );
        final userId = _viewModel.userId;
        final gsmNumber = _viewModel.gsmNumber;

        if (userId != null && gsmNumber != null) {
          _viewModel.resetVerificationFlags();
          // Navigate and wait for result
          final result = await context.push(
            '/two-factor-auth',
            extra: {'userId': userId, 'gsmNumber': gsmNumber},
          );

          // If verification successful, navigate to home
          if (result == 'success' && mounted) {
            context.go('/');
          }
        }
      } else if (_viewModel.requiresSmsVerification) {
        // Navigate to SMS verification page
        debugPrint(
          "SMS Verification required, navigating to SMS verification page.",
        );
        final userId = _viewModel.userId;
        final gsmNumber = _viewModel.gsmNumber;

        if (userId != null && gsmNumber != null) {
          _viewModel.resetVerificationFlags();
          // Navigate and wait for result
          final result = await context.push(
            '/sms-verification',
            extra: {'userId': userId, 'gsmNumber': gsmNumber},
          );

          // If verification successful, navigate to home
          if (result == 'success' && mounted) {
            context.go('/');
          }
        }
      } else if (_viewModel.loginSuccessful) {
        // Direct login without SMS verification
        debugPrint("Login Successful, navigating to home.");
        context.go('/');
      }
      // Update loading state
      setState(() {
        // This is primarily to rebuild if _isLoading changes,
        // though other properties might also require a rebuild.
      });
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppTheme.primaryColor, AppTheme.accentColor],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('lib/assets/images/PranomiLogo.png', height: 100),
              const SizedBox(height: 32),
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
                        "Kullanıcı Adı",
                        _viewModel.usernameController,
                      ),
                      // Use ViewModel's controller
                      const SizedBox(height: 16),
                      _inputField(
                        "Şifre",
                        _viewModel.passwordController,
                        // Use ViewModel's controller
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
      child: const Icon(Icons.lock_outline, color: Color(0xFFFFFFFF), size: 48),
    );
  }

  Widget _inputField(
    String hintText,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: AppTheme.white),
      decoration: InputDecoration(
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
      ),
    );
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
