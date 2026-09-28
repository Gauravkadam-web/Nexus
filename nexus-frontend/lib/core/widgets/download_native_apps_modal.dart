import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_config.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_context_extensions.dart';

/// Modal dialog providing direct downloads for Windows Desktop (.exe/.zip)
/// and Android Mobile (.apk) with a phone camera QR code scanner.
class DownloadNativeAppsModal extends StatelessWidget {
  const DownloadNativeAppsModal({super.key});

  /// Static helper to launch modal from anywhere in the app
  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => const DownloadNativeAppsModal(),
    );
  }

  Future<void> _launchDownloadUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open download link: $url')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Download failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 700;

    return Dialog(
      backgroundColor: context.cardBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: context.border),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: context.accentTint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.install_mobile, color: context.accent, size: 22),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Get Nexus Native Clients',
                                style: AppTypography.headlineMedium(isDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Download enterprise desktop and mobile clients for maximum performance, hardware acceleration, and instant notifications.',
                            style: AppTypography.bodySmall(isDark),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: context.textMuted, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Platform Cards Layout
                if (isMobile)
                  Column(
                    children: [
                      _buildWindowsCard(context, isDark),
                      const SizedBox(height: AppSpacing.lg),
                      _buildAndroidCard(context, isDark),
                    ],
                  )
                else
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildWindowsCard(context, isDark)),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(child: _buildAndroidCard(context, isDark)),
                    ],
                  ),

                const SizedBox(height: AppSpacing.lg),

                // Bottom security footer
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 16, color: context.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Digitally verified binaries • Direct cloud CDN distribution via Supabase Storage',
                        style: AppTypography.labelSmall(isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWindowsCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2638) : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.desktop_windows, color: Color(0xFF4F46E5), size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.border),
                ),
                child: Text(
                  'v1.0.0 (x64)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Nexus for Windows', style: AppTypography.headlineSmall(isDark)),
          const SizedBox(height: 4),
          Text('Windows 10 / 11 (64-bit Architecture)', style: AppTypography.labelSmall(isDark)),
          const SizedBox(height: AppSpacing.md),

          // Features List
          _buildFeatureBullet(context, isDark, Icons.bolt, 'Native Win32 hardware rendering'),
          _buildFeatureBullet(context, isDark, Icons.notifications_active, 'System tray & desktop alert badge'),
          _buildFeatureBullet(context, isDark, Icons.offline_bolt, 'Offline cached workstation mode'),
          const SizedBox(height: AppSpacing.lg),

          // Download CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchDownloadUrl(context, AppConfig.windowsExeDownloadUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download for Windows', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidCard(BuildContext context, bool isDark) {
    final apkUrl = AppConfig.androidApkDownloadUrl;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF142E28) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.android, color: Color(0xFF10B981), size: 28),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.border),
                ),
                child: Text(
                  '68.5 MB APK',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text('Nexus for Android', style: AppTypography.headlineSmall(isDark)),
          const SizedBox(height: 4),
          Text('Android 8.0+ (Impeller Vulkan Acceleration)', style: AppTypography.labelSmall(isDark)),
          const SizedBox(height: AppSpacing.md),

          // QR Code Scanner Box
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: apkUrl,
                version: QrVersions.auto,
                size: 130.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: Color(0xFF1E293B),
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.qr_code_scanner, size: 14, color: context.textMuted),
                const SizedBox(width: 4),
                Text(
                  'Scan with phone camera to download',
                  style: TextStyle(fontSize: 11, color: context.textMuted, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Direct Download Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchDownloadUrl(context, apkUrl),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.file_download_outlined, size: 18),
              label: const Text('Direct APK Download', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(BuildContext context, bool isDark, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: context.accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
