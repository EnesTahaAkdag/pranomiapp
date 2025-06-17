extension EnglishUpperCase on String {
  String toEnglishUpper() {
    return toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .replaceAll('I', 'i')
        .toUpperCase();
  }
}
