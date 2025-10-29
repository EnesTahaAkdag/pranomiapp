class Country {
  final int id;
  final String name;
  final String alpha2;

  Country({required this.id, required this.name, required this.alpha2});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name'] ?? '',
      alpha2: json['alpha2'] ?? '',
    );
  }

  String get alpha2Formatted => alpha2.toUpperCase();
}

class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    final idRaw = json['Id'];
    final idParsed = int.tryParse(idRaw?.toString() ?? '');

    if (idParsed == null) {
      throw FormatException("İl JSON id alanı geçersiz: $idRaw");
    }

    return City(id: idParsed, name: json['Name'] ?? '');
  }

  factory City.empty() => City(id: -1, name: '');
}

class District {
  final int id;
  final int cityId;
  final String name;

  District({required this.id, required this.cityId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: int.tryParse(json['Id']?.toString() ?? '') ?? 0,
      cityId: int.tryParse(json['CityId']?.toString() ?? '') ?? 0,
      name: json['Name'] ?? '',
    );
  }

  factory District.empty() => District(id: -1, name: '', cityId: -1);
}
