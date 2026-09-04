import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/colors.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class AppTheme {
  // 🔹 Centralized Semantic Tokens
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color cardColor = AppColors.cardColor;
  static const Color cardSurface = AppColors.cardSurface;
  static const Color secondarySurface = AppColors.secondarySurface;
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.secondary;
  static const Color accent = AppColors.accent;
  static const Color safe = AppColors.safe;
  static const Color warning = AppColors.warning;
  static const Color error = AppColors.error;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color border = AppColors.border;
  static const Color borderStrong = AppColors.borderStrong;

  // 🔹 Spacing Tokens
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

  // 🔹 Solid Orange Card Decoration (Solid #E65F2B with crisp white typography)
  static BoxDecoration solidOrangeCardDecoration({
    double radius = 12.0,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: primary,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: const Color(0xFFD34F1D),
        width: 1.0,
      ),
      boxShadow: hasShadow
          ? [
              const BoxShadow(
                color: Color.fromRGBO(230, 95, 43, 0.22),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  // 🔹 Corporate Control Center Card Decoration
  static BoxDecoration controlCardDecoration({
    Color? borderColor,
    Color? surfaceColor,
    double radius = 12.0,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      color: surfaceColor ?? surface,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor ?? border,
        width: 1.0,
      ),
      boxShadow: hasShadow
          ? [
              const BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.04),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  // Backward compatibility alias for existing references
  static BoxDecoration cyberCardDecoration({
    Color? borderColor,
    Color? surfaceColor,
    double radius = 12.0,
    bool hasGlow = false,
  }) {
    return controlCardDecoration(
      borderColor: borderColor,
      surfaceColor: surfaceColor,
      radius: radius,
    );
  }

  // 🔹 Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      canvasColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.outfit(color: textPrimary),
        bodyMedium: GoogleFonts.outfit(color: textPrimary),
        bodySmall: GoogleFonts.outfit(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: border, width: 1.0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 13),
      ),
    );
  }

  // 🔹 Dark Theme Fallback
  static ThemeData get darkTheme => lightTheme;
}
