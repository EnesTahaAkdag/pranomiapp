/// Base state class for SMS verification
/// Following Single Responsibility Principle - each state represents one condition
abstract class SmsVerificationState {
  const SmsVerificationState();
}

/// Initial state before countdown starts
class SmsVerificationInitial extends SmsVerificationState {
  const SmsVerificationInitial();
}

/// Countdown active state with remaining seconds
class SmsVerificationCountingDown extends SmsVerificationState {
  /// Remaining seconds in the countdown
  final int remainingSeconds;

  const SmsVerificationCountingDown(this.remainingSeconds);

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
class SmsVerificationExpired extends SmsVerificationState {
  const SmsVerificationExpired();
}

/// Success state when code is successfully verified
class SmsVerificationSuccess extends SmsVerificationState {
  final String message;

  const SmsVerificationSuccess({
    this.message = 'SMS kodu başarıyla doğrulandı.',
  });
}

/// Error state when verification fails
class SmsVerificationError extends SmsVerificationState {
  final String message;

  const SmsVerificationError(this.message);
}