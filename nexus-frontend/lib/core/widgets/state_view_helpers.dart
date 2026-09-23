import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'nexus_button.dart';

class NexusLoadingView extends StatelessWidget {
  final String message;

  const NexusLoadingView({
    super.key,
    this.message = 'Loading data...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class NexusErrorView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const NexusErrorView({
    super.key,
    this.title = 'Unable to Load Data',
    this.message = 'An unexpected error occurred while communicating with the server.',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF1F2),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: const Color(0xFFFECDD3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFE11D48), size: 36),
              const SizedBox(height: AppSpacing.sm),
              Text(
                title,
                style: AppTypography.titleSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF9F1239),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(context).copyWith(color: const Color(0xFF881337)),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.md),
                NexusButton(
                  text: 'Retry Request',
                  icon: Icons.refresh_rounded,
                  onPressed: onRetry,
                  variant: NexusButtonVariant.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NexusEmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onAction;

  const NexusEmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.textMuted),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.md),
              NexusButton(
                text: actionText!,
                onPressed: onAction,
                variant: NexusButtonVariant.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
