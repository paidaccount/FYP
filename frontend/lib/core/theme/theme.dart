import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vanet_mobile/core/theme/colors.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

class AppTheme {
  // 🔹 Centralized Semantic Tokens
  static const Color background = AppColors.background;
  static const Color surface = AppColors.surface;
  static const Color cardColor = AppColors.cardColor;
  static const Color cardSurface = AppColors.cardSurface;
  static const Color secondarySurface = AppColors.secondarySurface;
  static const Color primary = AppColors.primary;
  static const Color primaryLight = AppColors.primaryLight;
  static const Color secondary = AppColors.secondary;
  static const Color accent = AppColors.accent;
  static const Color aiHighlight = AppColors.aiHighlight;
  static const Color safe = AppColors.safe;
  static const Color safeLight = AppColors.safeLight;
  static const Color warning = AppColors.warning;
  static const Color warningLight = AppColors.warningLight;
  static const Color error = AppColors.error;
  static const Color errorLight = AppColors.errorLight;
  static const Color textPrimary = AppColors.textPrimary;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textTertiary = AppColors.textTertiary;
  static const Color border = AppColors.border;
  static const Color borderStrong = AppColors.borderStrong;

  // 🔹 Spacing Tokens
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);

  // 🔹 Solid Signature Brand Card Decoration
  static BoxDecoration solidOrangeCardDecoration({
    double radius = 14.0,
    bool hasShadow = true,
  }) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: hasShadow
          ? [
              BoxShadow(
                color: const Color(0xFFEA580C).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ]
          : null,
    );
  }

  // 🔹 Cyber-Dark Control Surface Card Decoration
  static BoxDecoration controlCardDecoration({
    Color? borderColor,
    Color? surfaceColor,
    double radius = 14.0,
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
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : null,
    );
  }

  // Backward compatibility alias
  static BoxDecoration cyberCardDecoration({
    Color? borderColor,
    Color? surfaceColor,
    double radius = 14.0,
    bool hasGlow = false,
  }) {
    return controlCardDecoration(
      borderColor: borderColor,
      surfaceColor: surfaceColor,
      radius: radius,
    );
  }

  // 🔹 Dark Theme Configuration (Default)
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      cardColor: surface,
      canvasColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimary,
        onError: Colors.white,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        displayMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        displaySmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold),
        headlineSmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700),
        titleLarge: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 18),
        titleMedium: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
        titleSmall: GoogleFonts.outfit(color: textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5),
        bodyLarge: GoogleFonts.outfit(color: textPrimary, fontSize: 14),
        bodyMedium: GoogleFonts.outfit(color: textPrimary, fontSize: 13),
        bodySmall: GoogleFonts.outfit(color: textSecondary, fontSize: 11.5),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
        titleTextStyle: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: borderStrong, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 13),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: secondarySurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primary, width: 1.8),
        ),
        labelStyle: GoogleFonts.outfit(color: textSecondary, fontSize: 13),
        hintStyle: GoogleFonts.outfit(color: textTertiary, fontSize: 13.5),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
      ),
    );
  }

  // 🔹 Light Theme Alias
  static ThemeData get lightTheme => darkTheme;
}
