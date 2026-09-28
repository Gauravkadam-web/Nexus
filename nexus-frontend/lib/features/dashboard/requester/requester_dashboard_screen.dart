import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context_extensions.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/nexus_button.dart';
import '../../../core/widgets/nexus_data_table.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/status_badge.dart';
import '../../auth/presentation/auth_state_provider.dart';
import '../../case/domain/case_model.dart';
import '../../case/presentation/case_state_provider.dart';

class RequesterDashboardScreen extends ConsumerWidget {
  const RequesterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final caseState = ref.watch(caseStateProvider);
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    return AppShell(
      currentPath: '/dashboard/requester',
      title: 'Requester Portal',
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveLayout.isMobile(context)
              ? AppSpacing.mobileGutter
              : AppSpacing.desktopGutter,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Welcome & Primary Action Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      children: [
                        Text(
                          'Welcome back, ${user?.name.split(' ').first ?? 'Sarah'}',
                          style: AppTypography.displayLarge(isDark).copyWith(fontSize: 24),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.statusClosedBgDark : AppColors.statusClosedBgLight,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                            border: Border.all(
                              color: isDark ? AppColors.statusClosedTextDark : AppColors.statusClosedTextLight,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.statusClosedTextDark : AppColors.statusClosedTextLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Operational',
                                style: TextStyle(
                                  color: isDark ? AppColors.statusClosedTextDark : AppColors.statusClosedTextLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Acme Corp Enterprise Portal • All systems normal',
                      style: AppTypography.bodySmall(isDark),
                    ),
                  ],
                ),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!ResponsiveLayout.isMobile(context)) ...[
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                        label: Text(
                          'Help Center',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                      ),
                    ],
                    NexusButton(
                      text: 'Report a Case',
                      icon: Icons.add,
                      onPressed: () => context.go('/cases/new'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 2. KPI Telemetry Row (4 cards with sparklines)
            _buildKpiGrid(context, isDark, caseState.requesterStats),
            const SizedBox(height: AppSpacing.xl),

            // 3. Action Required Callout Banner (Soft Apricot Tint)
            _buildActionRequiredBanner(context, isDark),
            const SizedBox(height: AppSpacing.xl),

            // 4. Cases Section Header
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('My Submitted Cases', style: AppTypography.headlineSmall(isDark)),
                    Text(
                      'Manage active tickets, review investigation logs, and track milestone SLAs.',
                      style: AppTypography.bodySmall(isDark),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        size: 16,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text('All Cases (${caseState.cases.length})', style: AppTypography.labelSmall(isDark)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // 5. Data Table Grid (Enterprise Table with Row Hover)
            NexusDataTable<CaseModel>(
              columns: const [
                NexusColumn(label: 'Case ID', width: 140),
                NexusColumn(label: 'Subject & Description', flex: 3),
                NexusColumn(label: 'Category', flex: 1),
                NexusColumn(label: 'Status', width: 140),
                NexusColumn(label: 'Milestone Progress', flex: 2),
                NexusColumn(label: 'Actions', width: 110, alignment: Alignment.centerRight),
              ],
              items: caseState.cases,
              isLoading: caseState.isLoading,
              onRowTap: (item) => context.go('/cases/${item.id}/track'),
              cellBuilder: (context, item, index) {
                return [
                  // Case ID with JetBrains Mono Capsule
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: context.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(color: context.border),
                    ),
                    child: Text(item.id, style: AppTypography.codeSmall(context)),
                  ),

                  // Subject & Title
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        item.description,
                        style: AppTypography.bodySmall(context).copyWith(fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),

                  // Category
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.accentTint,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      item.categoryName ?? 'IT Support',
                      style: TextStyle(
                        color: context.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // Status Badge
                  StatusBadge(status: item.status),

                  // Milestone Progress Bar
                  _buildMilestoneStepper(context, item.milestoneStep),

                  // Action Button
                  IconButton(
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    color: context.textSecondary,
                    onPressed: () => context.go('/cases/${item.id}/track'),
                  ),
                ];
              },
              mobileCardBuilder: (context, item, index) => _buildCaseCard(context, item),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiGrid(BuildContext context, bool isDark, RequesterDashboardStats? stats) {
    final isMobile = ResponsiveLayout.isMobile(context);

    final kpis = [
      KpiCard(
        title: 'Active Cases',
        value: '${stats?.activeCases ?? 3} Open',
        subtitle: '1 Investigating • 2 Triage',
        icon: Icons.pending_actions_outlined,
        accentColor: isDark ? AppColors.statusTriageTextDark : AppColors.statusTriageTextLight,
        showSparkline: true,
      ),
      KpiCard(
        title: 'Awaiting Your Reply',
        value: '${stats?.awaitingReply ?? 1} Urgent',
        subtitle: 'Operator requested log file',
        icon: Icons.mark_email_unread_outlined,
        accentColor: isDark ? AppColors.statusWaitingTextDark : AppColors.statusWaitingTextLight,
        valueColor: isDark ? AppColors.statusWaitingTextDark : AppColors.statusWaitingTextLight,
        showSparkline: true,
      ),
      KpiCard(
        title: 'Resolved Cases',
        value: '${stats?.resolvedCount ?? 14} Closed',
        subtitle: '100% verified resolution',
        icon: Icons.task_alt_outlined,
        accentColor: isDark ? AppColors.statusClosedTextDark : AppColors.statusClosedTextLight,
        showSparkline: true,
      ),
      KpiCard(
        title: 'Avg. Turnaround',
        value: '${stats?.avgTurnaroundHours ?? 4.2} hrs',
        subtitle: '98% within SLA window',
        icon: Icons.speed_outlined,
        accentColor: isDark ? AppColors.statusReportedTextDark : AppColors.statusReportedTextLight,
        showSparkline: true,
      ),
    ];

    if (isMobile) {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.15,
        children: kpis,
      );
    }

    return Row(
      children: kpis
          .map((kpi) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: kpi,
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActionRequiredBanner(BuildContext context, bool isDark) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final actionButtons = Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        OutlinedButton(
          onPressed: () => context.go('/cases/NEX-2026-0042/track'),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: context.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            backgroundColor: context.cardBg,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text('View Case', style: AppTypography.bodySmall(context).copyWith(fontWeight: FontWeight.w600)),
        ),
        NexusButton(
          text: 'Reply & Upload Log',
          icon: Icons.upload_file,
          height: 36,
          onPressed: () => context.go('/cases/NEX-2026-0042/track'),
        ),
      ],
    );

    if (isMobile) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.statusWaitingBgDark : AppColors.statusWaitingBgLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: (isDark ? AppColors.statusWaitingTextDark : AppColors.statusWaitingTextLight).withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.cardBg,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                  ),
                  child: Icon(
                    Icons.priority_high,
                    size: 18,
                    color: isDark ? AppColors.statusWaitingTextDark : AppColors.statusWaitingTextLight,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.xs,
                    runSpacing: 2,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: context.cardBg,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text('NEX-2026-0042', style: AppTypography.codeSmall(context)),
                      ),
                      Text(
                        'needs your attention',
                        style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Operator Elena Vance requested your VPN / Envoy debug client logs to trace proxy disconnection.',
              style: AppTypography.bodySmall(context),
            ),
            const SizedBox(height: AppSpacing.sm),
            actionButtons,
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.statusWaitingBgDark : AppColors.statusWaitingBgLight,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: (isDark ? AppColors.statusWaitingTextDark : AppColors.statusWaitingTextLight).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.cardBg,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
            ),
            child: Icon(
              Icons.priority_high,
              size: 20,
              color: isDark ? AppColors.statusWaitingTextDark : AppColors.statusWaitingTextLight,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.xs,
                  runSpacing: 2,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: context.cardBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: Text('NEX-2026-0042', style: AppTypography.codeSmall(context)),
                    ),
                    Text(
                      'needs your immediate attention',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Operator Elena Vance requested your VPN / Envoy debug client logs to trace proxy disconnection.',
                  style: AppTypography.bodySmall(context),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          actionButtons,
        ],
      ),
    );
  }

  Widget _buildCaseCard(BuildContext context, CaseModel item) {
    final formattedDate = DateFormat('MMM dd, yyyy').format(item.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.cardPaddingMobile),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.surfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(item.id, style: AppTypography.codeSmall(context)),
              ),
              StatusBadge(status: item.status),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(item.title, style: AppTypography.titleMedium(context)),
          const SizedBox(height: 2),
          Text(
            item.description,
            style: AppTypography.bodySmall(context),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildMilestoneStepper(context, item.milestoneStep),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Reported: $formattedDate', style: AppTypography.labelSmall(context)),
              TextButton(
                onPressed: () => context.go('/cases/${item.id}/track'),
                child: const Text('Track Details ➔', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneStepper(BuildContext context, int currentStep) {
    final steps = ['Reported', 'In Progress', 'Resolved', 'Closed'];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepIndex = (index ~/ 2) + 1;
          final isCompleted = currentStep > stepIndex;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted
                  ? context.accent
                  : context.border,
            ),
          );
        } else {
          final stepNum = (index ~/ 2) + 1;
          final isDone = currentStep >= stepNum;

          return Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: isDone
                  ? context.accent
                  : context.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(
                color: isDone
                    ? context.accent
                    : context.border,
                width: 1.5,
              ),
            ),
            child: isDone
                ? const Icon(Icons.check, size: 8, color: Colors.white)
                : null,
          );
        }
      }),
    );
  }
}
