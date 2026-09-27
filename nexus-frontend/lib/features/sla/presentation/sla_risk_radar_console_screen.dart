import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../data/sla_api.dart';
import '../domain/sla_model.dart';

/// SCR-12: SLA Risk Radar & Escalation Console Screen
/// Multi-tier SLA governance console featuring fleet health gauges,
/// real-time countdown timers, at-risk case clusters, and one-click two-phase escalation triggers.
class SlaRiskRadarConsoleScreen extends ConsumerStatefulWidget {
  const SlaRiskRadarConsoleScreen({super.key});

  @override
  ConsumerState<SlaRiskRadarConsoleScreen> createState() => _SlaRiskRadarConsoleScreenState();
}

class _SlaRiskRadarConsoleScreenState extends ConsumerState<SlaRiskRadarConsoleScreen> {
  String _selectedFilter = 'ALL'; // ALL, IMMINENT, WATCH, ESCALATED
  List<SlaRiskCaseModel> _atRiskCases = [];
  List<SlaRiskCaseModel> _breachedCases = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSlaData();
  }

  Future<void> _loadSlaData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      SlaApi().getAtRiskCases(),
      SlaApi().getBreachedCases(),
    ]);

    final riskRes = results[0] as dynamic;
    final breachRes = results[1] as dynamic;

    if (mounted) {
      if (riskRes.success && riskRes.data != null) {
        setState(() {
          _atRiskCases = riskRes.data as List<SlaRiskCaseModel>;
          _breachedCases = breachRes.success && breachRes.data != null ? (breachRes.data as List<SlaRiskCaseModel>) : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = riskRes.error ?? 'Failed to load SLA radar telemetry';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      currentPath: '/sla/risk-console',
      title: 'SLA Risk Radar',
      child: ResponsiveLayout(
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
          _buildLiveSyncTelemetryStrip(context),
          const SizedBox(height: AppSpacing.sm),
          _buildKpiSummaryGrid(context),
          const SizedBox(height: AppSpacing.sm),
          _buildSlaFleetHealthCard(context),
          const SizedBox(height: AppSpacing.sm),
          _buildProactiveRebalanceCard(context),
          const SizedBox(height: AppSpacing.sm),
          _buildFilterTabs(context),
          const SizedBox(height: AppSpacing.sm),
          _buildAtRiskCasesList(context),
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
          _buildLiveSyncTelemetryStrip(context),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildKpiSummaryGrid(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildSlaFleetHealthCard(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildProactiveRebalanceCard(context),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterTabs(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildAtRiskCasesList(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveSyncTelemetryStrip(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D9488),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'US-East-Sys04 SLA Cluster',
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleSmall(context).copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('v4.19', style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontFamily: 'monospace')),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sync, size: 12, color: AppColors.accentPrimary),
                SizedBox(width: 4),
                Text(
                  'Live Sync (3s)',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiSummaryGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: isWide ? 1.5 : 1.15,
          children: [
            _buildKpiCard(
              title: 'IMMINENT',
              value: '03',
              subtext: '<30m Critical',
              color: const Color(0xFFE11D48),
              bg: const Color(0xFFFFE4E6),
              icon: Icons.error_outline,
            ),
            _buildKpiCard(
              title: 'WATCH',
              value: '07',
              subtext: '<2h Elevated',
              color: const Color(0xFFD97706),
              bg: const Color(0xFFFEF3C7),
              icon: Icons.access_time,
            ),
            _buildKpiCard(
              title: 'HEALTHY',
              value: '32',
              subtext: '76.2% On-Track',
              color: const Color(0xFF0D9488),
              bg: const Color(0xFFCCFBF1),
              icon: Icons.check_circle_outline,
            ),
            _buildKpiCard(
              title: 'DEFENDED',
              value: '14',
              subtext: '100% Breaches Defended',
              color: const Color(0xFF6366F1),
              bg: const Color(0xFFEEF2FF),
              icon: Icons.shield_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtext,
    required Color color,
    required Color bg,
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
              Icon(icon, size: 16, color: color),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              subtext,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlaFleetHealthCard(BuildContext context) {
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
                'SLA Fleet Health Distribution',
                style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('42 Total', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              // Circular score badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFCCFBF1),
                  border: Border.all(color: const Color(0xFF0D9488), width: 4),
                ),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('94%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                      Text('Safe', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(0xFF0D9488))),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  children: [
                    _buildHealthDistributionRow('Safe Velocity (>4h)', '32 Cases', const Color(0xFF0D9488)),
                    const SizedBox(height: 6),
                    _buildHealthDistributionRow('Moderate Watch (<2h)', '07 Cases', const Color(0xFFD97706)),
                    const SizedBox(height: 6),
                    _buildHealthDistributionRow('Imminent Threat (<30m)', '03 Cases', const Color(0xFFE11D48)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDistributionRow(String label, String count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildProactiveRebalanceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 16)),
                  SizedBox(width: 6),
                  Text(
                    'AI Workload Rebalance',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('+8.4% SAFE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9333EA))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Reallocating 2 stalled P2 cases from David Ross to Sarah Jenkins recovers 18 minutes of shift safety headroom.',
            style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                onPressed: () => _showFeedbackToast('Rebalance strategy triggered', Icons.check, const Color(0xFF0D9488)),
                child: const Text('Execute Rebalance', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context) {
    final filters = [
      {'id': 'ALL', 'label': 'All Radar (42)'},
      {'id': 'IMMINENT', 'label': '🔴 Imminent (3)'},
      {'id': 'WATCH', 'label': '🟡 Watch (7)'},
      {'id': 'ESCALATED', 'label': '⚡ Escalated (2)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFFEEF2FF),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.accentPrimary : AppColors.borderLight,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFilter = f['id']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAtRiskCasesList(BuildContext context) {
    if (_isLoading) {
      return const NexusLoadingView(message: 'Calculating dynamic SLA burn velocity & risk trajectories...');
    }
    if (_errorMessage != null) {
      return NexusErrorView(message: _errorMessage!, onRetry: _loadSlaData);
    }

    List<SlaRiskCaseModel> displayCases = [];
    if (_selectedFilter == 'ALL') {
      displayCases = [..._breachedCases, ..._atRiskCases];
    } else if (_selectedFilter == 'IMMINENT') {
      displayCases = _atRiskCases.where((c) => c.remainingMinutes <= 30).toList();
    } else if (_selectedFilter == 'WATCH') {
      displayCases = _atRiskCases.where((c) => c.remainingMinutes > 30).toList();
    } else if (_selectedFilter == 'ESCALATED') {
      displayCases = _breachedCases;
    }

    if (displayCases.isEmpty) {
      return const NexusEmptyView(
        title: 'No Cases at SLA Risk',
        message: 'All active cases are currently within normal SLA operational parameters.',
        icon: Icons.shield_outlined,
      );
    }

    return Column(
      children: displayCases.map((c) {
        final isBreached = c.remainingMinutes <= 0;
        final isImminent = c.remainingMinutes > 0 && c.remainingMinutes <= 30;
        final countdownText = isBreached
            ? '🔥 BREACHED (${c.remainingMinutes.abs()}m ago)'
            : '⏳ ${c.remainingMinutes}m Left';

        final consumedPercent = (c.breachProbability * 100).toInt().clamp(10, 100);

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildRadarCaseCard(
            caseId: c.caseNumber.isNotEmpty ? c.caseNumber : c.caseId,
            title: c.title,
            severity: c.priority,
            status: c.status,
            assignee: c.assignedOperator.isNotEmpty ? c.assignedOperator : 'Unassigned',
            consumedPercent: consumedPercent,
            countdownText: countdownText,
            escalationTier: isBreached ? 'BREACH ESCALATED' : (isImminent ? 'TIER 2 IMMINENT' : 'MONITORING'),
            isBreached: isBreached,
            isImminent: isImminent,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRadarCaseCard({
    required String caseId,
    required String title,
    required String severity,
    required String status,
    required String assignee,
    required int consumedPercent,
    required String countdownText,
    required String escalationTier,
    required bool isBreached,
    required bool isImminent,
  }) {
    final alertColor = isBreached
        ? const Color(0xFFE11D48)
        : isImminent
            ? const Color(0xFFE11D48)
            : const Color(0xFFD97706);
    final alertBg = isBreached || isImminent ? const Color(0xFFFFE4E6) : const Color(0xFFFEF3C7);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isImminent ? const Color(0xFFFDA4AF) : AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    caseId.length > 16 ? 'NEX-${caseId.substring(0, 8).toUpperCase()}' : caseId,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentPrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      severity,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: alertBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  countdownText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: alertColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          // SLA Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (consumedPercent / 100).clamp(0.0, 1.0),
                    backgroundColor: const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(alertColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$consumedPercent% SLA Consumed',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: alertColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    assignee,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF5FF),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      escalationTier,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showFeedbackToast('Tier 2 Escalation confirmed & broadcasted', Icons.bolt, const Color(0xFFE11D48)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '⚡ Escalation Trigger',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFE11D48)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => context.go('/cases/$caseId'),
                    child: const Text(
                      'Open Studio ↗',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.accentPrimary),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
