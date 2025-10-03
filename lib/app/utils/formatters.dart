import 'package:intl/intl.dart';

/// Utility class for formatting currency and dates
class Formatters {
  /// Format currency amount with proper locale and symbol
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '₹',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Format currency amount without symbol (just numbers)
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return formatter.format(amount);
  }

  /// Format date in a readable format
  static String formatDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  /// Format date and time in a readable format
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy - hh:mm a');
    return formatter.format(date);
  }

  /// Format date in short format (MM/dd/yyyy)
  static String formatDateShort(DateTime date) {
    final formatter = DateFormat('MM/dd/yyyy');
    return formatter.format(date);
  }

  /// Get relative time (e.g., "2 days ago", "Today")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays > 1 && difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return formatDate(date);
    }
  }

  /// Format number with thousands separator
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0', 'en_US');
    return formatter.format(number);
  }

  /// Format percentage
  static String formatPercentage(double percentage) {
    final formatter = NumberFormat('#0.0%', 'en_US');
    return formatter.format(percentage);
  }

  /// Parse currency string to double
  static double parseCurrency(String value) {
    // Remove currency symbols and commas
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanValue) ?? 0.0;
  }

  /// Validate if string is a valid currency amount
  static bool isValidCurrency(String value) {
    if (value.isEmpty) return false;
    
    // Remove currency symbols and commas for validation
    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
    
    if (cleanValue.isEmpty) return false;
    
    final amount = double.tryParse(cleanValue);
    return amount != null && amount > 0;
  }
}
