import 'package:pranomiapp/Helper/StringExtensions/StringExtensions.dart';
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
  String countryIso2;
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
    required this.countryIso2,
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
      'TaxOffice': taxOffice.isEmpty ? null : taxOffice,
      'TaxNumber': taxNumber.isEmpty ? null : taxNumber,
      'Email': email.isEmpty ? null : email,
      'Iban': iban.isEmpty ? null : iban,
      'Address': address.isEmpty ? null : address,
      'Phone': phone.isEmpty ? null : phone,
      'CountryIso2': countryIso2.toEnglishUppers(),
      'City': city.isEmpty ? null : city,
      'District': district.isEmpty ? null : district,
      'IsActive': isActive,
      'Type': type.name,
      'HasOpeningBalance': hasOpeningBalance,
      'OpeningBalance': hasOpeningBalance ? openingBalance : null,
    };
  }
}
