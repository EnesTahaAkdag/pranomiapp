import 'package:pranomiapp/features/authentication/domain/authentication_type_enums.dart';

class LoginResponseModel {
  final String apiKey;
  final String apiSecret;
  final PraNomiSubscriptionTypeEnum subscriptionType;
  final bool isEInvoiceActive;

  LoginResponseModel({
    required this.apiKey,
    required this.apiSecret,
    required this.subscriptionType,
    required this.isEInvoiceActive,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      apiKey: json['ApiKey'].toString(),
      apiSecret: json['ApiSecret'].toString(),
      subscriptionType: parseSubscriptionType(json['SubscriptionType']),
      isEInvoiceActive:
          json['IsEInvoiceActive'].toString().toLowerCase() == 'true',
    );
  }
}

class LoginResponse {
  final bool success;
  final LoginResponseModel? item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  LoginResponse({
    required this.success,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['Success'] ?? false,
      item:
          json['Item'] != null
              ? LoginResponseModel.fromJson(json['Item'])
              : null,
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}
