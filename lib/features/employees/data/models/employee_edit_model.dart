import '../../../customers/domain/customer_type_enum.dart';

class EmployeeResponseModel {
  List<String> errorMessages;
  List<String> successMessages;
  List<String> warningMessages;

  EmployeeResponseModel({
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory EmployeeResponseModel.fromJson(Map<String, dynamic> json) {
    return EmployeeResponseModel(
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}

class EmployeeEditModel {
  String name;
  String code;
  bool isCompany;
  String taxOffice;
  String taxNumber;
  String email;
  String iban;
  String address;
  String phone;
  String countryIso2;
  String city;
  String district;
  bool isActive;
  CustomerTypeEnum type;
  int id;

  EmployeeEditModel({
    required this.name,
    required this.code,
    required this.isCompany,
    required this.taxOffice,
    required this.taxNumber,
    required this.email,
    required this.iban,
    required this.address,
    required this.phone,
    required this.countryIso2,
    required this.city,
    required this.district,
    required this.isActive,
    required this.type,
    required this.id,
  });

  factory EmployeeEditModel.fromJson(Map<String, dynamic> json) {
    return EmployeeEditModel(
      name: json['Name'] ?? '',
      code: json['Code'] ?? '',
      isCompany: json['IsCompany'],
      taxOffice: json['TaxOffice'] ?? '',
      taxNumber: json['TaxNumber'] ?? '',
      email: json['Email'] ?? '',
      iban: json['Iban'] ?? '',
      address: json['Address'] ?? '',
      phone: json['Phone'] ?? '',
      countryIso2: json['CountryIso2'] ?? '',
      city: json['City'] ?? '',
      district: json['District'] ?? '',
      isActive: json['isActive'] ?? true,
      type: customerType(json['Type']),
      id: json['Id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'Name': name,
    'Code': code,
    'IsCompany': isCompany,
    'TaxOffice': taxOffice,
    'TaxNumber': taxNumber,
    'Email': email.isEmpty ? null : email,
    'Iban': iban,
    'Address': address,
    'Phone': phone,
    'CountryIso2': countryIso2,
    'City': city,
    'District': district,
    'IsActive': isActive,
    'Type': type.name,
    'Id': id,
  };
}
