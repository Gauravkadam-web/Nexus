import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context_extensions.dart';

/// Dedicated public screen accessible via `/downloads`
/// Allows users and enterprise teams to download Windows & Android clients.
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open link: $url')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: context.surface,
      appBar: AppBar(
        backgroundColor: context.cardBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/auth/login');
            }
          },
        ),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Center(
                child: Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('Nexus Downloads', style: AppTypography.headlineSmall(isDark)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: context.border, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? AppSpacing.md : AppSpacing.xxl,
          vertical: AppSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hero Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: context.accentTint,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: context.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars, size: 16, color: context.accent),
                      const SizedBox(width: 6),
                      Text('Official Enterprise Releases', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.accent)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Install Nexus on Your Devices',
                  style: AppTypography.displayLarge(isDark),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Text(
                    'Experience low-latency case triage, hardware-accelerated 60fps rendering, and direct push alerts on desktop and mobile.',
                    style: AppTypography.bodyMedium(isDark),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Platform Cards
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
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(child: _buildAndroidCard(context, isDark)),
                    ],
                  ),

                const SizedBox(height: AppSpacing.xxl),

                // Security & Checksum Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, size: 20, color: context.accent),
                          const SizedBox(width: AppSpacing.sm),
                          Text('Enterprise Security & Integrity Guarantee', style: AppTypography.headlineSmall(isDark)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'All binaries are compiled through reproducible release pipelines, verified with AOT optimizations, and distributed via secure Supabase Storage CDN. Zero external telemetry or untracked analytics.',
                        style: AppTypography.bodySmall(isDark),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildPill(context, isDark, 'Windows x64 Portable', 'v1.0.0'),
                          _buildPill(context, isDark, 'Android APK', '68.5 MB ARM64'),
                          _buildPill(context, isDark, 'Backend API', 'Render Cloud HTTPS'),
                        ],
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
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2638) : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.desktop_windows, color: Color(0xFF4F46E5), size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.border),
                ),
                child: Text('Windows 10 / 11 (.exe)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Nexus Desktop Client', style: AppTypography.headlineMedium(isDark)),
          const SizedBox(height: 6),
          Text('Standalone Windows setup installer (.exe) with automatic desktop icon and start menu search.', style: AppTypography.bodySmall(isDark)),
          const SizedBox(height: AppSpacing.lg),

          _buildCheckItem(context, isDark, 'Single-file setup wizard installer (.exe)'),
          _buildCheckItem(context, isDark, 'Native Win32 hardware acceleration & 60fps rendering'),
          _buildCheckItem(context, isDark, 'Automatic Desktop icon & Start menu search integration'),
          _buildCheckItem(context, isDark, 'Full-screen 3-column operator workstation layout'),
          const SizedBox(height: AppSpacing.xl),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(context, AppConfig.windowsExeDownloadUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.download, size: 20),
              label: const Text('Download Windows Setup (.exe)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidCard(BuildContext context, bool isDark) {
    final apkUrl = AppConfig.androidApkDownloadUrl;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF142E28) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.android, color: Color(0xFF10B981), size: 32),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.surfaceElevated,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.border),
                ),
                child: Text('68.5 MB • Android 8.0+', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Nexus Mobile Client', style: AppTypography.headlineMedium(isDark)),
          const SizedBox(height: 6),
          Text('Hardware-accelerated mobile client with 5-destination bottom navigation and instant incident triage.', style: AppTypography.bodySmall(isDark)),
          const SizedBox(height: AppSpacing.md),

          // Embedded QR Code
          Center(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
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
                size: 140.0,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1E293B)),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF1E293B)),
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
                Text('Scan with your phone camera to download directly', style: TextStyle(fontSize: 12, color: context.textMuted)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _launchUrl(context, apkUrl),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.textPrimary,
                side: BorderSide(color: context.border),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.file_download_outlined, size: 20),
              label: const Text('Download Android APK', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(BuildContext context, bool isDark, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: context.accent),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: TextStyle(fontSize: 13, color: context.textSecondary))),
        ],
      ),
    );
  }

  Widget _buildPill(BuildContext context, bool isDark, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: context.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$title: ', style: TextStyle(fontSize: 12, color: context.textMuted)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: context.textPrimary)),
        ],
      ),
    );
  }
}
