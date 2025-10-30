import 'package:intl/intl.dart';

/// Centralized formatters to avoid creating new instances in build methods.
/// Creating NumberFormat and DateFormat objects is expensive and should be done once.
class AppFormatters {
  AppFormatters._();

  /// Turkish currency formatter without symbol (e.g., "1.234,56")
  static final NumberFormat currency = NumberFormat.currency(
    locale: 'tr_TR',
    decimalDigits: 2,
    symbol: '',
  );

  /// Turkish currency formatter with TL symbol (e.g., "1.234,56 TL")
  static final NumberFormat currencyWithSymbol = NumberFormat.currency(
    locale: 'tr_TR',
    decimalDigits: 2,
    symbol: '₺',
  );

  /// Turkish decimal formatter (e.g., "1.234,56")
  static final NumberFormat decimal = NumberFormat.decimalPattern('tr_TR');

  /// Turkish decimal formatter with specific digits
  static NumberFormat decimalWithDigits(int digits) {
    return NumberFormat.decimalPatternDigits(
      locale: 'tr_TR',
      decimalDigits: digits,
    );
  }

  /// Short date format (e.g., "31.12.2024")
  static final DateFormat dateShort = DateFormat('dd.MM.yyyy', 'tr_TR');

  /// Medium date format (e.g., "31 Aralık 2024")
  static final DateFormat dateMedium = DateFormat('dd MMMM yyyy', 'tr_TR');

  /// Long date format (e.g., "31 Aralık 2024 Salı")
  static final DateFormat dateLong = DateFormat('dd MMMM yyyy EEEE', 'tr_TR');

  /// Date with time (e.g., "31.12.2024 14:30")
  static final DateFormat dateTime = DateFormat('dd.MM.yyyy HH:mm', 'tr_TR');

  /// Full date and time (e.g., "31.12.2024 14:30:45")
  static final DateFormat dateTimeFull = DateFormat('dd.MM.yyyy HH:mm:ss', 'tr_TR');

  /// Time only (e.g., "14:30")
  static final DateFormat timeShort = DateFormat('HH:mm', 'tr_TR');

  /// Month and year (e.g., "Aralık 2024")
  static final DateFormat monthYear = DateFormat('MMMM yyyy', 'tr_TR');

  /// Format currency value with Turkish locale
  static String formatCurrency(num? value) {
    if (value == null) return '0,00';
    return currency.format(value);
  }

  /// Format currency value with symbol
  static String formatCurrencyWithSymbol(num? value) {
    if (value == null) return '₺0,00';
    return currencyWithSymbol.format(value);
  }

  /// Format date to short format
  static String formatDate(DateTime? date) {
    if (date == null) return '';
    return dateShort.format(date);
  }

  /// Format date with time
  static String formatDateTime(DateTime? date) {
    if (date == null) return '';
    return dateTime.format(date);
  }
}