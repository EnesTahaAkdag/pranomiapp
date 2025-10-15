import 'package:pranomiapp/features/authentication/domain/authentication_type_enums.dart';

class SmsVerificationModel {
  final String apiKey;
  final String apiSecret;
  final PraNomiSubscriptionTypeEnum subscriptionType;
  final bool isEInvoiceActive;

  SmsVerificationModel({
    required this.apiKey,
    required this.apiSecret,
    required this.subscriptionType,
    required this.isEInvoiceActive,
  });

  factory SmsVerificationModel.fromJson(Map<String, dynamic> json) {
    return SmsVerificationModel(
      apiKey: json['ApiKey'].toString(),
      apiSecret: json['ApiSecret'].toString(),
      subscriptionType: parseSubscriptionType(json['SubscriptionType']),
      isEInvoiceActive:
      json['IsEInvoiceActive'].toString().toLowerCase() == 'true',
    );
  }
}

class SmsVerificationResponse {
  final bool success;
  final int statusCode;
  final SmsVerificationModel? item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  SmsVerificationResponse({
    required this.success,
    required this.statusCode,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory SmsVerificationResponse.fromJson(Map<String, dynamic> json) {
    return SmsVerificationResponse(
      success: json['Success'].toString().toLowerCase() == 'true',
      statusCode: int.parse(json['StatusCode'].toString()),
      item: json['Item'] != null
          ? SmsVerificationModel.fromJson(json['Item'])
          : null,
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}