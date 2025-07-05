extension EnglishUpperCase on String {
  String toEnglishUppers() {
    return toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .toUpperCase();
  }
}

extension UpperCase on String {
  String toUpper() {
    return toLowerCase().toUpperCase();
  }
}

extension StringExtensions on String {
  String toEnglishUpper() {
    return toUpperCase()
        .replaceAll('İ', 'I')
        .replaceAll('Ş', 'S')
        .replaceAll('Ğ', 'G')
        .replaceAll('Ü', 'U')
        .replaceAll('Ö', 'O')
        .replaceAll('Ç', 'C')
        .replaceAll('ı', 'I');
  }
}

extension TurkishCaseExtensions on String {
  String toTurkishProperCase() {
    final lowered = toLowerCase()
        .replaceAll('i', 'i')
        .replaceAll('ı', 'ı')
        .replaceAll('İ', 'i')
        .replaceAll('I', 'ı');
    return lowered.isNotEmpty
        ? '${lowered[0].toUpperCase()}${lowered.substring(1)}'
        : '';
  }
}
