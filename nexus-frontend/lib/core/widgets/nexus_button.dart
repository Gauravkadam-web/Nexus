import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

enum NexusButtonVariant { primary, secondary, ghost, danger }
typedef ButtonVariant = NexusButtonVariant;
enum ButtonSize { small, medium, large }

class NexusButton extends StatelessWidget {
  final String? text;
  final String? label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final NexusButtonVariant variant;
  final ButtonSize? size;
  final bool isLoading;
  final double? width;
  final double height;

  const NexusButton({
    super.key,
    this.text,
    this.label,
    this.onPressed,
    this.icon,
    this.variant = NexusButtonVariant.primary,
    this.size,
    this.isLoading = false,
    this.width,
    this.height = 44.0,
  });

  String get effectiveText => text ?? label ?? '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case NexusButtonVariant.primary:
        bg = isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary;
        fg = isDark ? Colors.black : Colors.white;
        break;
      case NexusButtonVariant.secondary:
        bg = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        border = BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder);
        break;
      case NexusButtonVariant.ghost:
        bg = Colors.transparent;
        fg = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
        break;
      case NexusButtonVariant.danger:
        bg = isDark ? AppColors.statusBreachedBgDark : AppColors.statusBreachedBgLight;
        fg = isDark ? AppColors.statusBreachedTextDark : AppColors.statusBreachedTextLight;
        break;
    }

    final buttonChild = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                effectiveText,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          );

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            side: border,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: buttonChild,
      ),
    );
  }
}
