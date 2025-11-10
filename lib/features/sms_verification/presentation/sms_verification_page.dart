import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pranomiapp/core/theme/app_theme.dart';
import 'package:pranomiapp/core/widgets/app_loading_indicator.dart';
import 'package:pranomiapp/features/sms_verification/presentation/sms_verification_state.dart';
import 'package:pranomiapp/features/sms_verification/presentation/sms_verification_view_model.dart';
import 'package:provider/provider.dart';

/// SMS Verification Page with countdown timer
/// Following MVVM pattern with Provider for state management
class SmsVerificationPage extends StatelessWidget {
  /// Phone number for verification (will be masked)
  final String phoneNumber;

  /// User ID from login response
  final int? userId;

  /// GSM number from login response
  final String? gsmNumber;

  const SmsVerificationPage({
    super.key,
    this.phoneNumber = '*********51',
    this.userId,
    this.gsmNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap with ChangeNotifierProvider to provide ViewModel
    return ChangeNotifierProvider(
      create:
          (_) => SmsVerificationViewModel(
            phoneNumber: phoneNumber,
            userId: userId,
            gsmNumber: gsmNumber,
          ),
      child: const _SmsVerificationContent(),
    );
  }
}

/// Internal widget that consumes the ViewModel
class _SmsVerificationContent extends StatefulWidget {
  const _SmsVerificationContent();

  @override
  State<_SmsVerificationContent> createState() =>
      _SmsVerificationContentState();
}

class _SmsVerificationContentState extends State<_SmsVerificationContent> {
  // Controllers for 6 PIN input fields
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  // Focus nodes for PIN input fields
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    // Clean up controllers and focus nodes
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  /// Handles PIN input field changes
  void _onPinChanged(
    int index,
    String value,
    SmsVerificationViewModel viewModel,
  ) {
    if (value.isNotEmpty) {
      // Move to next field if not the last one
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field - hide keyboard
        _focusNodes[index].unfocus();
      }
    }

    // Update verification code in ViewModel
    final code = _controllers.map((c) => c.text).join();
    viewModel.updateVerificationCode(code);
  }

  /// Manually verifies the code when Onayla button is pressed
  Future<void> _verifyCode(SmsVerificationViewModel viewModel) async {
    final code = _controllers.map((c) => c.text).join();

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen 6 haneli kodu giriniz.'),
          backgroundColor: AppTheme.errorColor,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    await viewModel.verifyCode(code);

    // Check if verification was successful
    if (mounted && viewModel.state is SmsVerificationSuccess) {
      // Navigate back to login with success result
      context.pop('success');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        scrolledUnderElevation: 0, // Kaydırma sırasında elevation değişimini engeller

        title: const Text(
          'SMS Doğrulama',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<SmsVerificationViewModel>(
        builder: (context, viewModel, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 32),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.sms_outlined,
                    size: 40,
                    color: AppTheme.accentColor,
                  ),
                ),

                const SizedBox(height: 24),

                // Title
                const Text(
                  'SMS Doğrulaması Yapmanız Gerekiyor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppTheme.textBlack87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Description
                Text(
                  '${viewModel.getMaskedPhoneNumber()} numarasına gelen 6 haneli onay kodunu giriniz.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Countdown Timer Display
                _buildCountdownDisplay(viewModel),

                const SizedBox(height: 32),

                // PIN Input Fields
                _buildPinInputFields(viewModel),

                const SizedBox(height: 24),

                // State-based Messages
                _buildStateMessage(viewModel),

                const SizedBox(height: 24),

                // Onayla (Verify) Button
                _buildVerifyButton(viewModel),

              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the countdown timer display
  Widget _buildCountdownDisplay(SmsVerificationViewModel viewModel) {
    final state = viewModel.state;

    if (state is SmsVerificationCountingDown) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.timer_outlined,
              color: AppTheme.accentColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Kalan Süre: ${state.formattedTime}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentColor,
              ),
            ),
          ],
        ),
      );
    } else if (state is SmsVerificationExpired) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.timer_off_outlined,
              color: AppTheme.errorColor,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Süre Doldu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.errorColor,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Builds the 6-digit PIN input fields
  Widget _buildPinInputFields(SmsVerificationViewModel viewModel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Container(
          width: 45,
          height: 55,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textBlack87,
            ),
            decoration: InputDecoration(
              counterText: '',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.gray200, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: AppTheme.accentColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: AppTheme.white,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) => _onPinChanged(index, value, viewModel),
            onTap: () {
              _controllers[index].clear();
            },
          ),
        );
      }),
    );
  }

  /// Builds state-based messages (success/error)
  Widget _buildStateMessage(SmsVerificationViewModel viewModel) {
    final state = viewModel.state;

    if (state is SmsVerificationSuccess) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.successColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: AppTheme.successColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    } else if (state is SmsVerificationError) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.errorColor, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppTheme.errorColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                state.message,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  /// Builds the verify (Onayla) button
  Widget _buildVerifyButton(SmsVerificationViewModel viewModel) {
    final isEnabled =
        viewModel.verificationCode.length == 6 && !viewModel.isVerifying;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isEnabled ? () => _verifyCode(viewModel) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accentColor,
          disabledBackgroundColor: AppTheme.gray200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 2,
        ),
        child:
            viewModel.isVerifying
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: AppLoadingIndicator(size: 24),
                )
                : Text(
                  'Onayla',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? AppTheme.textWhite : AppTheme.textGray,
                  ),
                ),
      ),
    );
  }

}
