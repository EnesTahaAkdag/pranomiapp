extension EnglishUpperCase on String {
  String toEnglishUppers() {
    return toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'i')
        .toUpperCase();
  }
}

extension PhoneNumberExtension on String {
  String formatPhoneNumber() {
    String cleaned = replaceAll(RegExp(r'\D'), '');

    if (cleaned.length != 10) return this;

    return '(${cleaned.substring(0, 3)}) ${cleaned.substring(3, 6)} ${cleaned.substring(6, 8)} ${cleaned.substring(8, 10)}';
  }

  String unformatPhoneNumber() {
    return replaceAll(RegExp(r'\D'), '');
  }
}


// extension UpperCase on String {
//   String toUpper() {
//     return toLowerCase().toUpperCase();
//   }
// }

// extension StringExtensions on String {
//   String toEnglishUpper() {
//     return toUpperCase()
//         .replaceAll('İ', 'I')
//         .replaceAll('Ş', 'S')
//         .replaceAll('Ğ', 'G')
//         .replaceAll('Ü', 'U')
//         .replaceAll('Ö', 'O')
//         .replaceAll('Ç', 'C')
//         .replaceAll('ı', 'I');
//   }
// }

// extension TurkishCaseExtensions on String {
//   String toTurkishProperCase() {
//     final lowered = toLowerCase()
//         .replaceAll('i', 'i')
//         .replaceAll('ı', 'ı')
//         .replaceAll('İ', 'i')
//         .replaceAll('I', 'ı');
//     return lowered.isNotEmpty
//         ? '${lowered[0].toUpperCase()}${lowered.substring(1)}'
//         : '';
//   }
// }

// String normalize(String input) {
//   return input
//       .toLowerCase()
//       .replaceAll('i̇', 'i')
//       .replaceAll('ı', 'i')
//       .replaceAll('ğ', 'g')
//       .replaceAll('ü', 'u')
//       .replaceAll('ş', 's')
//       .replaceAll('ö', 'o')
//       .replaceAll('ç', 'c')
//       .replaceAll('â', 'a')
//       .replaceAll('î', 'i')
//       .replaceAll('û', 'u')
//       .replaceAll(RegExp(r'\s+'), '')
//       .trim();
// }
