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
        .replaceAll('Ç', 'C');
  }
}
