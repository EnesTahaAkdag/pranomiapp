import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pranomiapp/core/di/injection.dart';
import 'package:pranomiapp/core/services/onesignal_service.dart';
import 'package:pranomiapp/features/sms_verification/data/sms_verification_service.dart';
import 'package:pranomiapp/features/sms_verification/presentation/sms_verification_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ViewModel for SMS verification with countdown timer
/// Following MVVM pattern with Provider for state management
/// Single Responsibility: Manages SMS verification countdown and user interactions
class SmsVerificationViewModel extends ChangeNotifier {
  // Private state, exposed through getter
  SmsVerificationState _state = const SmsVerificationInitial();

  /// Current state of SMS verification
  SmsVerificationState get state => _state;

  /// Timer instance for countdown
  Timer? _timer;

  /// Total countdown duration in seconds (3 minutes = 180 seconds)
  static const int _countdownDuration = 180;

  /// Phone number to be displayed (masked)
  final String phoneNumber;

  /// User ID for verification (from login response)
  final int? userId;

  /// GSM number for verification (from login response)
  final String? gsmNumber;

  /// SMS Verification Service
  final SmsVerificationService _smsService = locator<SmsVerificationService>();

  /// Current verification code entered by user (6 digits)
  String _verificationCode = '';

  /// Loading state for verification
  bool _isVerifying = false;
  bool get isVerifying => _isVerifying;

  /// Constructor with phone number and optional user data
  SmsVerificationViewModel({
    required this.phoneNumber,
    this.userId,
    this.gsmNumber,
  }) {
    // Auto-start countdown when ViewModel is created
    startCountdown();
  }

  /// Gets the current verification code
  String get verificationCode => _verificationCode;

  /// Updates the verification code
  void updateVerificationCode(String code) {
    _verificationCode = code;
    notifyListeners();
  }

  /// Starts the countdown timer from 180 seconds
  void startCountdown() {
    // Cancel existing timer if any
    _timer?.cancel();

    // Reset verification code
    _verificationCode = '';

    // Set initial countdown state
    _updateState(const SmsVerificationCountingDown(_countdownDuration));

    // Create periodic timer that ticks every second
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = _state;

      if (currentState is SmsVerificationCountingDown) {
        final newRemainingSeconds = currentState.remainingSeconds - 1;

        if (newRemainingSeconds <= 0) {
          // Countdown finished, cancel timer and update to expired state
          timer.cancel();
          _updateState(const SmsVerificationExpired());
        } else {
          // Update countdown with new remaining seconds
          _updateState(SmsVerificationCountingDown(newRemainingSeconds));
        }
      }
    });
  }

  /// Restarts the countdown (for resend functionality)
  void restartCountdown() {
    startCountdown();
  }

  /// Masks phone number to show only last 2 digits
  /// Example: "+905551234567" becomes "*********67"
  String getMaskedPhoneNumber() {
    if (phoneNumber.isEmpty) return '';

    // If phone number has less than 2 characters, return as is
    if (phoneNumber.length < 2) return phoneNumber;

    // Get last 2 digits
    final lastTwoDigits = phoneNumber.substring(phoneNumber.length - 2);



    // Create mask with asterisks
    final maskedPart = '*' * (phoneNumber.length - 2);

    return '$maskedPart$lastTwoDigits';
  }

  /// Verifies the SMS code with the API
  Future<void> verifyCode(String code) async {
    if (code.length != 6) {
      _updateState(const SmsVerificationError('Lütfen 6 haneli kodu giriniz.'));
      return;
    }

    // Check if we have the required data for verification
    if (userId == null || gsmNumber == null) {
      _updateState(const SmsVerificationError('Doğrulama bilgileri eksik.'));
      return;
    }

    // Set loading state
    _isVerifying = true;
    notifyListeners();

    // Cancel timer when verification starts
    _timer?.cancel();

    try {
      // Call API to verify SMS code
      final response = await _smsService.loginWithSmsVerification(
        code,
        userId!,
        gsmNumber!,
      );

      if (response != null && response.success && response.item != null) {
        // Verification successful - save credentials
        final apiInfo = response.item!;
        final prefs = locator<SharedPreferences>();
        await prefs.setString('apiKey', apiInfo.apiKey);
        await prefs.setString('apiSecret', apiInfo.apiSecret);
        await prefs.setString('subscriptionType', apiInfo.subscriptionType.name);
        await prefs.setBool('isEInvoiceActive', apiInfo.isEInvoiceActive);

        // Login to OneSignal with userId
        await OneSignalService.login(userId!);

        // Show success message
        final successMsg = response.successMessages.isNotEmpty
            ? response.successMessages.join('\n')
            : 'Doğrulama başarılı!';
        _updateState(SmsVerificationSuccess(message: successMsg));
      } else {
        // Verification failed
        final errorMsg = response?.errorMessages.isNotEmpty == true
            ? response!.errorMessages.join('\n')
            : 'SMS kodu hatalı veya süresi dolmuş.';
        _updateState(SmsVerificationError(errorMsg));
      }
    } catch (e) {
      _updateState(SmsVerificationError('Doğrulama başarısız: ${e.toString()}'));
      debugPrint('Error verifying SMS code: $e');
    } finally {
      _isVerifying = false;
      notifyListeners();
    }
  }

  /// Checks if countdown is active
  bool get isCountdownActive {
    return _state is SmsVerificationCountingDown;
  }

  /// Checks if countdown is expired
  bool get isCountdownExpired {
    return _state is SmsVerificationExpired;
  }

  /// Updates state and notifies listeners
  /// Private method to ensure encapsulation
  void _updateState(SmsVerificationState newState) {
    _state = newState;
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up timer to prevent memory leaks
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}