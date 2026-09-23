import 'package:flutter/material.dart';

/// Nexus sRGB Pastel & Slate Dual-Theme Color System
class AppColors {
  AppColors._();

  // === Light Mode (Crisp Slate) ===
  static const Color lightCanvas = Color(0xFFFAFAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // === Convenience Aliases ===
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color borderLight = lightBorder;
  static const Color borderDark = darkBorder;
  static const Color borderGrey = lightBorder;
  static const Color surfaceLight = lightSurface;
  static const Color surfaceDark = darkSurface;
  static const Color canvasLight = lightCanvas;
  static const Color canvasDark = darkCanvas;
  static const Color lightBackground = lightCanvas;
  static const Color darkBackground = darkCanvas;
  static const Color primary = accentPrimary;
  static const Color primaryBlue = accentPrimary;
  static const Color aiAccent = aiLilac;
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color aiBorderLight = Color(0x339333EA);
  static const Color aiBorderDark = Color(0x33C084FC);

  // === Dark Mode (Deep Obsidian) ===
  static const Color darkCanvas = Color(0xFF0D1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceElevated = Color(0xFF21262D);
  static const Color darkBorder = Color(0xFF30363D);
  static const Color darkTextPrimary = Color(0xFFF0F6FC);
  static const Color darkTextSecondary = Color(0xFF8B949E);
  static const Color darkTextMuted = Color(0xFF6E7681);

  // === Brand & Accent (Periwinkle & Sky) ===
  static const Color accentPrimary = Color(0xFF6366F1); // Pastel Indigo/Periwinkle
  static const Color accentPrimaryDark = Color(0xFF818CF8);
  static const Color accentTintLight = Color(0xFFEEF2FF);
  static const Color accentTintDark = Color(0xFF1E1E38);
  static const Color accentSkyLight = Color(0xFF0284C7);
  static const Color accentSkyDark = Color(0xFF38BDF8);

  // === AI Intelligence (Pastel Lilac - Non-Gimmicky) ===
  static const Color aiLilac = Color(0xFF9333EA);
  static const Color aiLilacDark = Color(0xFFC084FC);
  static const Color aiBgLight = Color(0xFFFAF5FF);
  static const Color aiBgDark = Color(0xFF251833);
  static const Color aiBorder = Color(0x33C084FC);

  // === Case Lifecycle Status Badges (Pastel Pairs: Text & Background) ===
  // 1. Reported (Slate)
  static const Color statusReportedTextLight = Color(0xFF64748B);
  static const Color statusReportedBgLight = Color(0xFFF1F5F9);
  static const Color statusReportedTextDark = Color(0xFF94A3B8);
  static const Color statusReportedBgDark = Color(0xFF1E293B);

  // 2. Understood / Triage (Sky Blue)
  static const Color statusTriageTextLight = Color(0xFF0284C7);
  static const Color statusTriageBgLight = Color(0xFFE0F2FE);
  static const Color statusTriageTextDark = Color(0xFF38BDF8);
  static const Color statusTriageBgDark = Color(0xFF0C2D48);

  // 3. Assigned (Periwinkle)
  static const Color statusAssignedTextLight = Color(0xFF6366F1);
  static const Color statusAssignedBgLight = Color(0xFFEEF2FF);
  static const Color statusAssignedTextDark = Color(0xFF818CF8);
  static const Color statusAssignedBgDark = Color(0xFF1E1E38);

  // 4. Investigating (Butter Honey)
  static const Color statusInvestigatingTextLight = Color(0xFFD97706);
  static const Color statusInvestigatingBgLight = Color(0xFFFEF3C7);
  static const Color statusInvestigatingTextDark = Color(0xFFFBBF24);
  static const Color statusInvestigatingBgDark = Color(0xFF382808);

  // 5. Waiting for Info (Apricot)
  static const Color statusWaitingTextLight = Color(0xFFEA580C);
  static const Color statusWaitingBgLight = Color(0xFFFFEDD5);
  static const Color statusWaitingTextDark = Color(0xFFFB923C);
  static const Color statusWaitingBgDark = Color(0xFF3D1B06);

  // 6. Resolution Proposed (Iris Purple)
  static const Color statusResolutionTextLight = Color(0xFF7C3AED);
  static const Color statusResolutionBgLight = Color(0xFFF3E8FF);
  static const Color statusResolutionTextDark = Color(0xFFA78BFA);
  static const Color statusResolutionBgDark = Color(0xFF2E1065);

  // 7. Closed / Confirmed (Sage Teal)
  static const Color statusClosedTextLight = Color(0xFF0D9488);
  static const Color statusClosedBgLight = Color(0xFFCCFBF1);
  static const Color statusClosedTextDark = Color(0xFF2DD4BF);
  static const Color statusClosedBgDark = Color(0xFF0D3331);

  // 8. SLA Breached / At-Risk (Coral Rose)
  static const Color statusBreachedTextLight = Color(0xFFE11D48);
  static const Color statusBreachedBgLight = Color(0xFFFFE4E6);
  static const Color statusBreachedTextDark = Color(0xFFFB7185);
  static const Color statusBreachedBgDark = Color(0xFF3D0C15);
}
