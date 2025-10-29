import 'package:pranomiapp/features/authentication/domain/authentication_type_enums.dart';

class ApiInfoModel {
  final String apiKey;
  final String apiSecret;
  final PraNomiSubscriptionTypeEnum subscriptionType;
  final bool isEInvoiceActive;

  ApiInfoModel({
    required this.apiKey,
    required this.apiSecret,
    required this.subscriptionType,
    required this.isEInvoiceActive,
  });

  factory ApiInfoModel.fromJson(Map<String, dynamic> json) {
    return ApiInfoModel(
      apiKey: json['ApiKey'].toString(),
      apiSecret: json['ApiSecret'].toString(),
      subscriptionType: parseSubscriptionType(json['SubscriptionType']),
      isEInvoiceActive:
      json['IsEInvoiceActive'].toString().toLowerCase() == 'true',
    );
  }
}

class LoginResponseModel {
  final bool hasActive2FA;
  final int userId;
  final String gsmNumber;
  final bool requireSms;
  final ApiInfoModel? apiInfo;

  LoginResponseModel({
    required this.hasActive2FA,
    required this.userId,
    required this.gsmNumber,
    required this.requireSms,
    this.apiInfo,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      hasActive2FA:
      json['HasActive2FA'].toString().toLowerCase() == 'true',
      userId: int.parse(json['UserId'].toString()),
      gsmNumber: json['GsmNumber'].toString(),
      requireSms:
      json['RequireSms'].toString().toLowerCase() == 'true',
      apiInfo: json['ApiInfo'] != null
          ? ApiInfoModel.fromJson(json['ApiInfo'])
          : null,
    );
  }
}

class LoginResponse {
  final bool success;
  final int statusCode;
  final LoginResponseModel? item;
  final List<String> errorMessages;
  final List<String> successMessages;
  final List<String> warningMessages;

  LoginResponse({
    required this.success,
    required this.statusCode,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['Success'].toString().toLowerCase() == 'true',
      statusCode: int.parse(json['StatusCode'].toString()),
      item: json['Item'] != null
          ? LoginResponseModel.fromJson(json['Item'])
          : null,
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}