class AuthenticationResult {
  final bool success;
  final String? successMessage;
  final String? errorMessage;
  final String? warningMessage;
  final AuthenticationAction? nextAction;
  final Map<String, dynamic>? data;

  AuthenticationResult({
    required this.success,
    this.successMessage,
    this.errorMessage,
    this.warningMessage,
    this.nextAction,
    this.data,
  });
}

enum AuthenticationAction {
  navigateToHome,
  navigateToSmsVerification,
  navigateToTwoFactorAuth,
  none,
}