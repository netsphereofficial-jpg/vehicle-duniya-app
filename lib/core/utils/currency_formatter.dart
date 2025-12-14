import 'package:intl/intl.dart';

/// Currency formatting utilities for Indian Rupees
class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _indianFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _indianFormatWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormat = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 1,
  );

  /// Format amount with Indian currency format (e.g., ₹1,23,456)
  static String format(double? amount) {
    if (amount == null) return '₹0';
    return _indianFormat.format(amount);
  }

  /// Format amount with decimals (e.g., ₹1,23,456.78)
  static String formatWithDecimals(double? amount) {
    if (amount == null) return '₹0.00';
    return _indianFormatWithDecimals.format(amount);
  }

  /// Format amount in compact form (e.g., ₹1.2L, ₹50K)
  static String formatCompact(double? amount) {
    if (amount == null) return '₹0';
    return _compactFormat.format(amount);
  }

  /// Format with custom label for lakhs and crores
  static String formatIndian(double? amount) {
    if (amount == null) return '₹0';

    if (amount >= 10000000) {
      // Crores
      final crores = amount / 10000000;
      return '₹${crores.toStringAsFixed(crores.truncate() == crores ? 0 : 2)} Cr';
    } else if (amount >= 100000) {
      // Lakhs
      final lakhs = amount / 100000;
      return '₹${lakhs.toStringAsFixed(lakhs.truncate() == lakhs ? 0 : 2)} L';
    } else if (amount >= 1000) {
      // Thousands
      final thousands = amount / 1000;
      return '₹${thousands.toStringAsFixed(thousands.truncate() == thousands ? 0 : 1)}K';
    }

    return format(amount);
  }

  /// Parse Indian formatted string to double
  static double? parse(String? value) {
    if (value == null || value.isEmpty) return null;

    // Remove currency symbol and spaces
    String cleanValue = value.replaceAll('₹', '').replaceAll(' ', '');

    // Handle compact formats
    if (cleanValue.toUpperCase().endsWith('CR')) {
      cleanValue = cleanValue.substring(0, cleanValue.length - 2);
      final num = double.tryParse(cleanValue.replaceAll(',', ''));
      return num != null ? num * 10000000 : null;
    } else if (cleanValue.toUpperCase().endsWith('L')) {
      cleanValue = cleanValue.substring(0, cleanValue.length - 1);
      final num = double.tryParse(cleanValue.replaceAll(',', ''));
      return num != null ? num * 100000 : null;
    } else if (cleanValue.toUpperCase().endsWith('K')) {
      cleanValue = cleanValue.substring(0, cleanValue.length - 1);
      final num = double.tryParse(cleanValue.replaceAll(',', ''));
      return num != null ? num * 1000 : null;
    }

    // Remove commas and parse
    return double.tryParse(cleanValue.replaceAll(',', ''));
  }

  /// Format price range
  static String formatRange(double? min, double? max) {
    if (min == null && max == null) return 'Any Price';
    if (min == null) return 'Up to ${formatCompact(max)}';
    if (max == null) return '${formatCompact(min)}+';
    return '${formatCompact(min)} - ${formatCompact(max)}';
  }
}
