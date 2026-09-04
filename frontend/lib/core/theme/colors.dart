import 'package:flutter/material.dart';

class AppColors {
  // 🔹 Main Background & Surfaces (Corporate Control Room)
  static const Color background = Color(0xFFF8F9FA);   // Main background
  static const Color surface = Color(0xFFFFFFFF);      // Primary card / surface
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color secondarySurface = Color(0xFFEDF0F2); // Subtle panel / secondary surface

  // 🔹 Typography & Borders
  static const Color textPrimary = Color(0xFF111827);    // Primary dark text / headings
  static const Color textSecondary = Color(0xFF6B7280);  // Secondary muted slate
  static const Color border = Color(0xFFE5E7EB);         // Subtle hairline border
  static const Color borderStrong = Color(0xFFD1D5DB);

  // 🔹 Primary Brand & Semantic Actions
  static const Color primary = Color(0xFFE65F2B);        // Automotive safety orange
  static const Color primaryVariant = Color(0xFFCC4E1D);
  static const Color secondary = Color(0xFF1F2937);      // Dark slate structural elements
  static const Color secondaryVariant = Color(0xFF111827);

  // 🔹 Domain Status Colors
  static const Color safe = Color(0xFF059669);           // Trusted / Connected / Safe
  static const Color accent = Color(0xFF059669);         // Alias for Safe
  static const Color warning = Color(0xFFD97706);        // Suspicious / Warning / Caution
  static const Color error = Color(0xFFDC2626);          // Malicious / Critical / Emergency

  // 🔹 Material Compatibility Tokens
  static const Color onPrimary = Colors.white;
  static const Color onSecondary = Colors.white;
  static const Color onBackground = Color(0xFF111827);
  static const Color onSurface = Color(0xFF111827);
  static const Color onError = Colors.white;
}
