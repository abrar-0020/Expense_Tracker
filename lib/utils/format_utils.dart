import 'package:intl/intl.dart';

/// Formatting Utilities
class FormatUtils {
  /// Format amount to currency string (₹ symbol)
  static String formatCurrency(double amount) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    return '₹${formatter.format(amount)}';
  }

  /// Format compact currency for charts (e.g., "5K", "2.5K")
  static String formatCompactCurrency(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }

  /// Format date to readable string (e.g., "25 Dec 2025")
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  /// Format date to short string (e.g., "25/12/2025")
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  /// Format month and year (e.g., "December 2025")
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Get month name (e.g., "December")
  static String getMonthName(int month) {
    final date = DateTime(2025, month, 1);
    return DateFormat('MMMM').format(date);
  }
}
