import 'package:flutter/material.dart';

/// App Constants
class AppConstants {
  // Predefined expense categories
  static const List<String> categories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Education',
    'Other',
  ];

  // Category icons mapping
  static const Map<String, IconData> categoryIcons = {
    'Food': Icons.restaurant,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt_long,
    'Health': Icons.health_and_safety,
    'Education': Icons.school,
    'Other': Icons.category,
  };

  // Category colors (soft pastel colors for modern UI)
  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFFFB6B9),
    'Transport': Color(0xFFBAE1FF),
    'Shopping': Color(0xFFFFDFB9),
    'Entertainment': Color(0xFFCDB4DB),
    'Bills': Color(0xFFFFAFCC),
    'Health': Color(0xFFA8DADC),
    'Education': Color(0xFFF1C0E8),
    'Other': Color(0xFFB8E0D2),
  };
}

/// App Theme Colors
class AppColors {
  static const Color primary = Color(0xFF0F766E); // Deep Teal (Luxury & Modern)
  static const Color secondary = Color(0xFFD97706); // Warm Gold
  static const Color background = Color(0xFFFAFAFA); // Very light grey
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color border = Color(0xFFE5E7EB);
}

/// Dark Theme Colors
class DarkAppColors {
  static const Color primary = Color(0xFF14B8A6); // Brighter Teal for dark mode
  static const Color secondary = Color(0xFFFBBF24); // Brighter Gold
  static const Color background = Color(0xFF111827); // Dark grey
  static const Color cardBackground = Color(0xFF1F2937); // Card dark grey
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF34D399);
  static const Color error = Color(0xFFF87171);
  static const Color border = Color(0xFF374151);
}
