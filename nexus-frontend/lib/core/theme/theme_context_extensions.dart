import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Context-aware theme extensions for clean, glare-free, and tokenized styling.
/// Eliminates raw hex values and scattered ternary `isDark ? ... : ...` checks.
extension NexusThemeContext on BuildContext {
  /// Whether the active theme is Dark (Obsidian) mode.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // === Surfaces & Backgrounds ===
  Color get canvas => isDark ? AppColors.darkCanvas : AppColors.lightCanvas;
  Color get surface => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get surfaceElevated => isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
  Color get cardBg => isDark ? AppColors.darkSurface : Colors.white;
  Color get cardBgElevated => isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF8FAFC);

  // === Borders & Dividers ===
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get borderSubtle => isDark ? const Color(0xFF262C36) : const Color(0xFFE2E8F0);

  // === Typography Colors ===
  Color get textPrimary => isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  Color get textMuted => isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  // === Brand & Accent ===
  Color get accent => isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
  Color get accentTint => isDark ? AppColors.accentTintDark : AppColors.accentTintLight;

  // === AI Intelligence ===
  Color get aiBg => isDark ? AppColors.aiBgDark : AppColors.aiBgLight;
  Color get aiLilac => isDark ? AppColors.aiLilacDark : AppColors.aiLilac;
  Color get aiBorder => isDark ? AppColors.aiBorderDark : AppColors.aiBorderLight;
}
