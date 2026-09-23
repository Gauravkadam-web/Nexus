import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class StatusBadge extends StatelessWidget {
  final dynamic status;
  final dynamic severity;
  final dynamic priority;
  final bool showDot;

  const StatusBadge({
    super.key,
    this.status,
    this.severity,
    this.priority,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rawValue = (status ?? severity ?? priority ?? 'REPORTED').toString();
    final statusStr = rawValue.contains('.') ? rawValue.split('.').last : rawValue;
    final normalized = statusStr.toUpperCase().replaceAll(' ', '_');

    Color fg;
    Color bg;
    String label = statusStr;

    switch (normalized) {
      case 'REPORTED':
        fg = isDark ? AppColors.statusReportedTextDark : AppColors.statusReportedTextLight;
        bg = isDark ? AppColors.statusReportedBgDark : AppColors.statusReportedBgLight;
        label = 'Reported';
        break;
      case 'UNDERSTOOD':
      case 'TRIAGE':
        fg = isDark ? AppColors.statusTriageTextDark : AppColors.statusTriageTextLight;
        bg = isDark ? AppColors.statusTriageBgDark : AppColors.statusTriageBgLight;
        label = 'Triage';
        break;
      case 'ASSIGNED':
        fg = isDark ? AppColors.statusAssignedTextDark : AppColors.statusAssignedTextLight;
        bg = isDark ? AppColors.statusAssignedBgDark : AppColors.statusAssignedBgLight;
        label = 'Assigned';
        break;
      case 'INVESTIGATING':
      case 'IN_PROGRESS':
        fg = isDark ? AppColors.statusInvestigatingTextDark : AppColors.statusInvestigatingTextLight;
        bg = isDark ? AppColors.statusInvestigatingBgDark : AppColors.statusInvestigatingBgLight;
        label = 'Investigating';
        break;
      case 'WAITING_FOR_INFO':
      case 'WAITING_FOR_REQUESTER':
      case 'PENDING_INFO':
        fg = isDark ? AppColors.statusWaitingTextDark : AppColors.statusWaitingTextLight;
        bg = isDark ? AppColors.statusWaitingBgDark : AppColors.statusWaitingBgLight;
        label = 'Waiting Info';
        break;
      case 'RESOLUTION_PROPOSED':
      case 'RESOLVED':
        fg = isDark ? AppColors.statusResolutionTextDark : AppColors.statusResolutionTextLight;
        bg = isDark ? AppColors.statusResolutionBgDark : AppColors.statusResolutionBgLight;
        label = 'Resolution Proposed';
        break;
      case 'CLOSED':
      case 'CONFIRMED':
        fg = isDark ? AppColors.statusClosedTextDark : AppColors.statusClosedTextLight;
        bg = isDark ? AppColors.statusClosedBgDark : AppColors.statusClosedBgLight;
        label = 'Closed';
        break;
      case 'BREACHED':
      case 'AT_RISK':
      case 'CRITICAL':
        fg = isDark ? AppColors.statusBreachedTextDark : AppColors.statusBreachedTextLight;
        bg = isDark ? AppColors.statusBreachedBgDark : AppColors.statusBreachedBgLight;
        label = 'SLA Breached';
        break;
      default:
        fg = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        bg = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: fg,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.02,
            ),
          ),
        ],
      ),
    );
  }
}
