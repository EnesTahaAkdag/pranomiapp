import '../../domain/customer_type_enum.dart';

class CustomerResponseModel {
  List<String> errorMessages;
  List<String> successMessages;
  List<String> warningMessages;

  CustomerResponseModel({
    required this.errorMessages,
    required this.successMessages,
    required this.warningMessages,
  });

  factory CustomerResponseModel.fromJson(Map<String, dynamic> json) {
    return CustomerResponseModel(
      errorMessages: List<String>.from(json['ErrorMessages'] ?? []),
      successMessages: List<String>.from(json['SuccessMessages'] ?? []),
      warningMessages: List<String>.from(json['WarningMessages'] ?? []),
    );
  }
}

class CustomerEditModel {
  String name;
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

  CustomerEditModel({
    required this.name,
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

  factory CustomerEditModel.fromJson(Map<String, dynamic> json) {
    return CustomerEditModel(
      name: json['Name'] ?? '',
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
