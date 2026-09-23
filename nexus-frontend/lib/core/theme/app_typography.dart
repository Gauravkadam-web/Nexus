import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static bool _resolveDark(dynamic param) {
    if (param is bool) return param;
    if (param is BuildContext) {
      return Theme.of(param).brightness == Brightness.dark;
    }
    return false;
  }

  // Headings (Outfit)
  static TextStyle displayLarge([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.outfit(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.02,
      height: 1.25,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle headlineMedium([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.outfit(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.015,
      height: 1.3,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle headlineSmall([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.outfit(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.01,
      height: 1.35,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  // Heading aliases
  static TextStyle headingLarge([dynamic param = false]) => displayLarge(param);
  static TextStyle headingMedium([dynamic param = false]) => headlineMedium(param);
  static TextStyle headingSmall([dynamic param = false]) => headlineSmall(param);

  // Body & Titles (Inter)
  static TextStyle titleMedium([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.01,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle titleSmall([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }

  static TextStyle bodyMedium([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.55,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
  }

  static TextStyle bodySmall([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.005,
      height: 1.45,
      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
    );
  }

  static TextStyle labelMedium([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.02,
      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
    );
  }

  static TextStyle labelSmall([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.04,
      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
    );
  }

  // Code & Monospace (JetBrains Mono)
  static TextStyle codeSmall([dynamic param = false]) {
    final isDark = _resolveDark(param);
    return GoogleFonts.jetBrainsMono(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
    );
  }
}
