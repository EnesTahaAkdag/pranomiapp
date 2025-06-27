class CustomerResponseModel {
  bool success;
  int statusCode;
  CustomerDetailModel item;
  List<String> errorMessages;
  List<String> successMessages;
  List<String> warningMessages;

  CustomerResponseModel({
    required this.success,
    required this.statusCode,
    required this.item,
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(
      success: json['Success'] ?? false,
      statusCode: json['StatusCode'] ?? 0,
      item: CustomerDetailModel.fromJson(json['Item']),
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}

class CustomerDetailModel {
  final int id;
  final String name;
  final String code;
  final String type;
  final String? phone;
  final String? email;
  final String? iban;
  final String? city;
  final String? district;
  final String countryIso2;
  final String? taxOffice;
  final String? taxNumber;
  final String? address;
  final bool active;
  final bool isCompany;
  final double balance;

  CustomerDetailModel({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    this.phone,
    this.email,
    this.iban,
    this.city,
    this.district,
    required this.countryIso2,
    this.taxOffice,
    this.taxNumber,
    this.address,
    required this.active,
    required this.isCompany,
    required this.balance,
  });

  factory CustomerDetailModel.fromJson(Map<String, dynamic> json) {
    return CustomerDetailModel(
      id: json['Id'] ?? 0,
      name: json['Name'] ?? '',
      code: json['Code'] ?? '',
      type: json['Type'] ?? '',
      phone: json['Phone'] ?? '',
      email: json['Email'] ?? '',
      iban: json['Iban'] ?? '',
      city: json['City'] ?? '',
      district: json['District'] ?? '',
      countryIso2: json['CountryIso2'] ?? '',
      taxOffice: json['TaxOffice'] ?? '',
      taxNumber: json['TaxNumber'] ?? '',
      address: json['Address'] ?? '',
      active: json['Active'] ?? true,
      isCompany: json['IsCompany'] ?? false,
      balance: (json['Balance'] ?? 0).toDouble(),
    );
  }
}
