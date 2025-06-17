import 'package:pranomiapp/Helpers/Methods/StringExtensions/StringExtensions.dart';
import 'package:pranomiapp/Models/TypeEnums/CustomerTypeEnum.dart';

class CustomerAddModel {
  String name;
  bool isCompany;
  String taxOffice;
  String taxNumber;
  String email;
  String iban;
  String address;
  String phone;
  String cuontryIso2;
  String city;
  String district;
  bool isActive;
  CustomerTypeEnum type;
  bool hasOpeningBalance;
  int openingBalance;

  CustomerAddModel({
    required this.name,
    required this.isCompany,
    required this.taxOffice,
    required this.taxNumber,
    required this.email,
    required this.iban,
    required this.address,
    required this.phone,
    required this.cuontryIso2,
    required this.city,
    required this.district,
    required this.isActive,
    required this.type,
    required this.hasOpeningBalance,
    required this.openingBalance,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'IsCompany': isCompany,
      'TaxOffice': taxOffice,
      'TaxNumber': taxNumber,
      'Email': email,
      'Iban': iban,
      'Address': address,
      'Phone': phone,
      'CountryIso2': cuontryIso2.toEnglishUpper(),
      'City': city,
      'District': district,
      'IsActive': isActive,
      'Type': type.toString(),
      'HasOpeningBalance': hasOpeningBalance,
      'OpeningBalance': openingBalance,
    };
  }
}
