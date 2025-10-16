/// Base state class for Two-Factor Authentication
/// Following Single Responsibility Principle - each state represents one condition
abstract class TwoFactorAuthState {
  const TwoFactorAuthState();
}

/// Initial state before countdown starts
class TwoFactorAuthInitial extends TwoFactorAuthState {
  const TwoFactorAuthInitial();
}

/// Countdown active state with remaining seconds
class TwoFactorAuthCountingDown extends TwoFactorAuthState {
  /// Remaining seconds in the countdown
  final int remainingSeconds;

  const TwoFactorAuthCountingDown(this.remainingSeconds);

  /// Convenience getter to check if countdown is active
  bool get isActive => remainingSeconds > 0;

  /// Format remaining seconds as MM:SS
  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Countdown expired state (reached 0 seconds)
class TwoFactorAuthExpired extends TwoFactorAuthState {
  const TwoFactorAuthExpired();
}

/// Success state when code is successfully verified
class TwoFactorAuthSuccess extends TwoFactorAuthState {
  final String message;

  const TwoFactorAuthSuccess({
    this.message = 'İki faktörlü doğrulama başarılı.',
  });
}

/// Error state when verification fails
class TwoFactorAuthError extends TwoFactorAuthState {
  final String message;

  const TwoFactorAuthError(this.message);
}
