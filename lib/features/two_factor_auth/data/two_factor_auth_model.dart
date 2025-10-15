import 'package:pranomiapp/features/authentication/domain/authentication_type_enums.dart';

/// Model for Two-Factor Authentication data
/// Contains API credentials and subscription information returned after successful 2FA verification
class TwoFactorAuthModel {
  final String apiKey;
  final String apiSecret;
  final PraNomiSubscriptionTypeEnum subscriptionType;
  final bool isEInvoiceActive;

  TwoFactorAuthModel({
    required this.apiKey,
    required this.apiSecret,
    required this.subscriptionType,
    required this.isEInvoiceActive,
  });

  factory TwoFactorAuthModel.fromJson(Map<String, dynamic> json) {
    return TwoFactorAuthModel(
      apiKey: json['ApiKey'].toString(),
      apiSecret: json['ApiSecret'].toString(),
      subscriptionType: parseSubscriptionType(json['SubscriptionType']),
      isEInvoiceActive:
          json['IsEInvoiceActive'].toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ApiKey': apiKey,
      'ApiSecret': apiSecret,
      'SubscriptionType': subscriptionType.name,
      'IsEInvoiceActive': isEInvoiceActive,
    };
  }
}

/// Response wrapper for Two-Factor Authentication API calls
/// Contains success status, messages, and the authentication data
class TwoFactorAuthResponse {
  final bool success;
  final int statusCode;
  final TwoFactorAuthModel? item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  TwoFactorAuthResponse({
    required this.success,
    required this.statusCode,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory TwoFactorAuthResponse.fromJson(Map<String, dynamic> json) {
    return TwoFactorAuthResponse(
      success: json['Success'].toString().toLowerCase() == 'true',
      statusCode: int.parse(json['StatusCode'].toString()),
      item: json['Item'] != null
          ? TwoFactorAuthModel.fromJson(json['Item'])
          : null,
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Success': success,
      'StatusCode': statusCode,
      'Item': item?.toJson(),
      'ErrorMessages': errorMessages,
      'SuccessMessages': successMessages,
      'WarningMessages': warningMessages,
    };
  }
}