import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../../admin/data/admin_api.dart';
import '../../admin/domain/admin_models.dart';
import '../../case/data/case_repository.dart';
import '../../case/domain/case_model.dart';

/// SCR-11: Team Lead Command & Workload Monitor Screen
/// Operations console for shift leaders featuring live capacity indicators,
/// dynamic operator workload cards, proactive AI rebalancing, and at-risk queues.
class TeamLeadCommandScreen extends ConsumerStatefulWidget {
  const TeamLeadCommandScreen({super.key});

  @override
  ConsumerState<TeamLeadCommandScreen> createState() => _TeamLeadCommandScreenState();
}

class _TeamLeadCommandScreenState extends ConsumerState<TeamLeadCommandScreen> {
  bool _isRebalanceDismissed = false;
  List<CaseModel> _teamCases = [];
  List<AdminUserModel> _operators = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      CaseRepository().getAssignedCases(),
      AdminApi().getUsers(),
    ]);

    final caseRes = results[0] as dynamic;
    final userRes = results[1] as dynamic;

    if (mounted) {
      if (caseRes.success && caseRes.cases != null) {
        setState(() {
          _teamCases = caseRes.cases as List<CaseModel>;
          _operators = userRes.success && userRes.data != null
              ? (userRes.data as List<AdminUserModel>).where((u) => u.role != 'REQUESTER').toList()
              : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = caseRes.error ?? 'Failed to load team data';
          _isLoading = false;
        });
      }
    }
  }

  void _showFeedbackToast(String message, IconData icon, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF131B2E),
        behavior: SnackBarBehavior.floating,
        content: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall(context).copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/dashboard/team-lead',
      title: 'Team Lead Command',
      child: _isLoading
          ? const NexusLoadingView(message: 'Loading shift & workload metrics...')
          : _errorMessage != null
              ? NexusErrorView(
                  title: 'Shift Load Error',
                  message: _errorMessage!,
                  onRetry: _loadDashboardData,
                )
              : ResponsiveLayout(
                  mobileBody: _buildMobileBody(context),
                  desktopBody: _buildDesktopBody(context),
                ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShiftControlHeader(context),
          const SizedBox(height: AppSpacing.sm),
          _buildShiftVitalMetricsGrid(context),
          const SizedBox(height: AppSpacing.sm),
          if (!_isRebalanceDismissed) ...[
            _buildAiWorkloadAlertBanner(context),
            const SizedBox(height: AppSpacing.sm),
          ],
          _buildOperatorsMonitorSection(context),
          const SizedBox(height: AppSpacing.sm),
          _buildAtRiskQueueSection(context),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShiftControlHeader(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildShiftVitalMetricsGrid(context),
                    const SizedBox(height: AppSpacing.md),
                    if (!_isRebalanceDismissed) ...[
                      _buildAiWorkloadAlertBanner(context),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    _buildOperatorsMonitorSection(context),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAtRiskQueueSection(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShiftControlHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF0D9488),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LIVE SHIFT OPERATIONS',
                      style: AppTypography.bodySmall(context).copyWith(
                        color: const Color(0xFF0D9488),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SecOps & Core SRE Team',
                  style: AppTypography.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.schedule, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'EMEA Core (08:00 - 16:00 UTC) • 8 Operators',
                      style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => _showFeedbackToast('AI Auto-Rebalancing executed across all queues', Icons.auto_awesome, const Color(0xFF9333EA)),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF9333EA)),
                  const SizedBox(width: 4),
                  Text(
                    'Auto-Rebalance',
                    style: AppTypography.bodySmall(context).copyWith(
                      color: const Color(0xFF9333EA),
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftVitalMetricsGrid(BuildContext context) {
    final operatorCount = _operators.length;
    final backlogCount = _teamCases.length;
    final criticalCount = _teamCases.where((c) => c.priority == 'CRITICAL' || c.priority == 'HIGH').length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.5 : 1.35,
          children: [
            _buildVitalMetricCard(
              title: 'OPERATORS',
              value: '$operatorCount',
              badgeText: 'Active Roster',
              badgeColor: const Color(0xFF0D9488),
              badgeBg: const Color(0xFFCCFBF1),
              icon: Icons.groups_outlined,
            ),
            _buildVitalMetricCard(
              title: 'ACTIVE BACKLOG',
              value: '$backlogCount',
              badgeText: '$criticalCount High/Crit',
              badgeColor: const Color(0xFFE11D48),
              badgeBg: const Color(0xFFFFE4E6),
              icon: Icons.inbox_outlined,
            ),
            _buildVitalMetricCard(
              title: 'SHIFT SLA',
              value: '98.2%',
              badgeText: 'On Track',
              badgeColor: const Color(0xFF0D9488),
              badgeBg: const Color(0xFFCCFBF1),
              icon: Icons.verified_outlined,
            ),
            _buildVitalMetricCard(
              title: 'AT-RISK LOAD',
              value: '$criticalCount',
              badgeText: 'Priority Monitor',
              badgeColor: const Color(0xFFD97706),
              badgeBg: const Color(0xFFFEF3C7),
              icon: Icons.tune,
            ),
          ],
        );
      },
    );
  }

  Widget _buildVitalMetricCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, size: 16, color: badgeColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiWorkloadAlertBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('✨', style: TextStyle(fontSize: 18)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'AI Imbalance Detected',
                      style: AppTypography.bodyMedium(context).copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF9333EA),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'AI Copilot',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'David Ross is at 95% capacity (8 active cases). Proactive auto-routing recommends delegating 2 unassigned P2 tickets directly to Sarah Jenkins.',
                  style: AppTypography.bodySmall(context).copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9333EA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 14),
                      label: const Text('Accept Plan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        setState(() => _isRebalanceDismissed = true);
                        _showFeedbackToast('Workload rebalance applied successfully', Icons.check_circle, const Color(0xFF0D9488));
                      },
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      onPressed: () => _showFeedbackToast('Opening Rebalance Reviewer Studio', Icons.rate_review, AppColors.accentPrimary),
                      child: const Text('Review', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorsMonitorSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Operators Workload',
                style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => _showFeedbackToast('Viewing all 8 rostered operators', Icons.groups, AppColors.accentPrimary),
                child: const Text('View All 8', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accentPrimary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildOperatorCard(
            name: 'Elena Vance',
            role: 'Lead Operator',
            activeCases: 3,
            maxCases: 6,
            statusLabel: 'AVAILABLE',
            statusColor: const Color(0xFF0D9488),
            statusBg: const Color(0xFFCCFBF1),
            avatarLetter: 'EV',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildOperatorCard(
            name: 'David Ross',
            role: 'Senior SRE',
            activeCases: 8,
            maxCases: 8,
            statusLabel: 'OVERLOADED',
            statusColor: const Color(0xFFE11D48),
            statusBg: const Color(0xFFFFE4E6),
            avatarLetter: 'DR',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildOperatorCard(
            name: 'Sarah Jenkins',
            role: 'SecOps Analyst',
            activeCases: 2,
            maxCases: 6,
            statusLabel: 'AVAILABLE',
            statusColor: const Color(0xFF0D9488),
            statusBg: const Color(0xFFCCFBF1),
            avatarLetter: 'SJ',
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildOperatorCard(
            name: 'Marcus Brody',
            role: 'Infra Specialist',
            activeCases: 5,
            maxCases: 6,
            statusLabel: 'OPTIMAL',
            statusColor: const Color(0xFF0284C7),
            statusBg: const Color(0xFFE0F2FE),
            avatarLetter: 'MB',
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorCard({
    required String name,
    required String role,
    required int activeCases,
    required int maxCases,
    required String statusLabel,
    required Color statusColor,
    required Color statusBg,
    required String avatarLetter,
  }) {
    final progress = activeCases / maxCases;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: statusBg,
                child: Text(
                  avatarLetter,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                    ),
                    Text(
                      role,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '$activeCases/$maxCases Cases',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAtRiskQueueSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Color(0xFFE11D48), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'At-Risk & Escalation Queue',
                    style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              InkWell(
                onTap: () => context.go('/sla/risk-console'),
                child: const Text(
                  'Open Radar ↗',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accentPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_teamCases.isEmpty)
            const NexusEmptyView(
              title: 'Queue Clear',
              message: 'No active cases in team backlog.',
              icon: Icons.check_circle_outline,
            )
          else ...[
            ..._teamCases.take(5).map((c) {
              final isCrit = c.priority == 'CRITICAL';
              final isHigh = c.priority == 'HIGH';
              final urgent = isCrit || c.status == 'ESCALATED';

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _buildAtRiskCaseItem(
                  caseId: c.caseNumber,
                  title: c.title,
                  severity: c.priority ?? c.severity,
                  assignee: c.assignedOperatorId != null ? 'Operator ${c.assignedOperatorId!.substring(0, 6)}' : 'Unassigned',
                  timeLeft: urgent ? '⏳ 28m Left' : (isHigh ? '⏳ 1h 15m Left' : 'Normal'),
                  isUrgent: urgent,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildAtRiskCaseItem({
    required String caseId,
    required String title,
    required String severity,
    required String assignee,
    required String timeLeft,
    required bool isUrgent,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFF1F2) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isUrgent ? const Color(0xFFFDA4AF) : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                caseId,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.accentPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFFFE4E6) : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  timeLeft,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isUrgent ? const Color(0xFFE11D48) : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assignee: $assignee',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
              InkWell(
                onTap: () => context.go('/cases/$caseId'),
                child: const Text(
                  'Triage Now',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentPrimary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
