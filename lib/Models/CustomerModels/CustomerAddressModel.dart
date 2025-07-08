class Country {
  final int id;
  final String name;
  final String alpha2;

  Country({required this.id, required this.name, required this.alpha2});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      alpha2: json['alpha2'] ?? '',
    );
  }

  String get alpha2Formatted => alpha2.toUpperCase();
}

class City {
  final int id;
  final String name;
  final String countryAlpha2;

  City({required this.id, required this.name, required this.countryAlpha2});

  factory City.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final idParsed = int.tryParse(idRaw?.toString() ?? '');

    if (idParsed == null) {
      throw FormatException("City JSON id alanı geçersiz: $idRaw");
    }

    return City(
      id: idParsed,
      name: json['name'] ?? '',
      countryAlpha2: json['countryAlpha2'] ?? '',
    );
  }

  factory City.empty() => City(id: -1, name: '', countryAlpha2: '');
}

class District {
  final int id;
  final int cityId;
  final String name;

  District({required this.id, required this.cityId, required this.name});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      cityId: int.tryParse(json['il_id']?.toString() ?? '') ?? 0,
      name: json['name'] ?? '',
    );
  }

  factory District.empty() => District(id: -1, name: '', cityId: -1);
}
