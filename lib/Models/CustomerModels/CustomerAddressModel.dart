import 'package:pranomiapp/Helpers/Methods/StringExtensions/StringExtensions.dart';

class Country {
  final int id;
  final String name;
  final String alpha2;

  Country({required this.id, required this.name, required this.alpha2});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(id: json['id'], name: json['name'], alpha2: json['alpha2']);
  }

  String get alpha2Formatted => alpha2.toEnglishUpper();
}

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(id: int.parse(json['id'].toString()), name: json['name']);
  }
}

class District {
  final int id;
  final int cityId;
  final String name;

  District({required this.id, required this.cityId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: int.parse(json['id'].toString()),
      cityId: int.parse(json['il_id'].toString()),
      name: json['name'],
    );
  }
}
