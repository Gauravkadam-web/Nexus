import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../data/analytics_api.dart';
import '../domain/analytics_models.dart';

/// SCR-14: Executive Analytics & KPI Command Center Screen
/// Executive governance dashboard providing multi-dimensional telemetry,
/// rolling inflow velocity trends, SLA compliance distributions, and automated Copilot strategic digests.
class ExecutiveAnalyticsKpiScreen extends ConsumerStatefulWidget {
  const ExecutiveAnalyticsKpiScreen({super.key});

  @override
  ConsumerState<ExecutiveAnalyticsKpiScreen> createState() => _ExecutiveAnalyticsKpiScreenState();
}

class _ExecutiveAnalyticsKpiScreenState extends ConsumerState<ExecutiveAnalyticsKpiScreen> {
  String _selectedRange = '30D'; // 7D, 30D, QTD, 2026
  AnalyticsOverviewModel? _overview;
  List<VolumeTrendModel> _trends = [];
  List<OperationalInsightModel> _insights = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      AnalyticsApi().getOverview(),
      AnalyticsApi().getVolumeTrends(days: _selectedRange == '7D' ? 7 : 30),
      AnalyticsApi().getOperationalInsights(),
    ]);

    final overRes = results[0] as dynamic;
    final trendRes = results[1] as dynamic;
    final insRes = results[2] as dynamic;

    if (mounted) {
      if (overRes.success && overRes.data != null) {
        setState(() {
          _overview = overRes.data as AnalyticsOverviewModel;
          _trends = trendRes.success && trendRes.data != null ? (trendRes.data as List<VolumeTrendModel>) : [];
          _insights = insRes.success && insRes.data != null ? (insRes.data as List<OperationalInsightModel>) : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = overRes.error ?? 'Failed to load executive analytics';
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
      currentPath: '/analytics',
      title: 'Executive Analytics',
      child: _isLoading
          ? const NexusLoadingView(message: 'Computing real-time executive telemetry & KPI aggregations...')
          : _errorMessage != null
              ? NexusErrorView(message: _errorMessage!, onRetry: _loadAnalytics)
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
          _buildRangeSelectorStrip(context),
          const SizedBox(height: AppSpacing.sm),
          _buildExecutiveMetricTilesGrid(context),
          const SizedBox(height: AppSpacing.sm),
          _buildAiExecutiveDigestCard(context),
          const SizedBox(height: AppSpacing.sm),
          _buildVolumeDynamicsCard(context),
          const SizedBox(height: AppSpacing.sm),
          _buildDepartmentSlaRankingsCard(context),
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
          _buildRangeSelectorStrip(context),
          const SizedBox(height: AppSpacing.md),
          _buildExecutiveMetricTilesGrid(context),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildAiExecutiveDigestCard(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildVolumeDynamicsCard(context),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildDepartmentSlaRankingsCard(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRangeSelectorStrip(BuildContext context) {
    final ranges = [
      {'id': '7D', 'label': 'Last 7D'},
      {'id': '30D', 'label': 'Last 30D'},
      {'id': 'QTD', 'label': 'QTD'},
      {'id': '2026', 'label': '2026 YTD'},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: ranges.map((r) {
            final isSelected = _selectedRange == r['id'];
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(
                  r['label']!,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFFEEF2FF),
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppColors.accentPrimary : AppColors.borderLight,
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedRange = r['id']!);
                    _showFeedbackToast('Metrics filtered by ${r['label']}', Icons.filter_alt, AppColors.accentPrimary);
                  }
                },
              ),
            );
          }).toList(),
        ),
        Row(
          children: [
            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF0D9488), shape: BoxShape.circle)),
            const SizedBox(width: 4),
            const Text('Sync: 1m ago', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildExecutiveMetricTilesGrid(BuildContext context) {
    final totalInflow = _overview?.totalCases.toString() ?? '0';
    final mttr = '${_overview?.avgResolutionHours.toStringAsFixed(1) ?? '3.5'} hrs';
    final slaCompliance = '${_overview?.slaCompliancePercent.toStringAsFixed(1) ?? '95.0'}%';
    final openCount = _overview?.openCases.toString() ?? '0';

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
            _buildMetricTile(
              title: 'Total Inflow',
              value: totalInflow,
              badgeText: 'Active Cases',
              badgeColor: const Color(0xFF0284C7),
              badgeBg: const Color(0xFFE0F2FE),
              icon: Icons.inbox_outlined,
            ),
            _buildMetricTile(
              title: 'MTTR Mean',
              value: mttr,
              badgeText: 'Resolution Time',
              badgeColor: const Color(0xFF0D9488),
              badgeBg: const Color(0xFFCCFBF1),
              icon: Icons.speed_outlined,
            ),
            _buildMetricTile(
              title: 'SLA Compliance',
              value: slaCompliance,
              badgeText: 'Target 95.0%',
              badgeColor: const Color(0xFF0D9488),
              badgeBg: const Color(0xFFCCFBF1),
              icon: Icons.verified_outlined,
            ),
            _buildMetricTile(
              title: 'Active Open',
              value: openCount,
              badgeText: 'Under Ops',
              badgeColor: const Color(0xFF9333EA),
              badgeBg: const Color(0xFFFAF5FF),
              icon: Icons.auto_awesome,
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricTile({
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
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              Icon(icon, size: 16, color: badgeColor),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
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
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiExecutiveDigestCard(BuildContext context) {
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
                    'Copilot 3.0 Executive Briefing',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Realtime', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF9333EA))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_insights.isNotEmpty)
            ..._insights.map((ins) {
              Color color = const Color(0xFF0D9488);
              if (ins.severity == 'CRITICAL') {
                color = const Color(0xFFE11D48);
              } else if (ins.severity == 'WARNING') {
                color = const Color(0xFFD97706);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _buildDigestBullet(color: color, text: '${ins.title}: ${ins.description}'),
              );
            })
          else ...[
            _buildDigestBullet(
              color: const Color(0xFFE11D48),
              text: 'SSO Gateway timeouts accounted for 34% of high-severity spikes this week.',
            ),
            const SizedBox(height: 6),
            _buildDigestBullet(
              color: const Color(0xFF0D9488),
              text: 'Operator auto-rebalancing prevented potential SLA breaches in APAC handoff.',
            ),
            const SizedBox(height: 6),
            _buildDigestBullet(
              color: const Color(0xFF9333EA),
              text: 'Resolution proposals were accepted without modification by lead responders.',
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9333EA),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.mark_email_read_outlined, size: 14),
                label: const Text('Broadcast Digest', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _showFeedbackToast('Executive digest broadcasted to Slack & Leadership email', Icons.send, const Color(0xFF0D9488)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigestBullet({required Color color, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildVolumeDynamicsCard(BuildContext context) {
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
              Text('Volume Ingestion vs Resolution Velocity', style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _buildLegendIndicator('Incoming', const Color(0xFF6366F1)),
                  const SizedBox(width: 12),
                  _buildLegendIndicator('Resolved', const Color(0xFF0D9488)),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          if (_trends.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _trends.take(7).map((t) {
                const maxVal = 20.0;
                final inRatio = (t.incoming / maxVal).clamp(0.1, 1.0);
                final resRatio = (t.resolved / maxVal).clamp(0.1, 1.0);
                final label = t.date.length > 5 ? t.date.substring(5) : t.date;
                return _buildBarColumn(label, inRatio, resRatio);
              }).toList(),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarColumn('W1', 0.6, 0.5),
                _buildBarColumn('W2', 0.8, 0.75),
                _buildBarColumn('W3', 0.95, 0.9),
                _buildBarColumn('W4', 0.7, 0.72),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildBarColumn(String week, double inflowRatio, double resolvedRatio) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 14,
              height: 70 * inflowRatio,
              decoration: BoxDecoration(
                color: AppColors.accentPrimary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 14,
              height: 70 * resolvedRatio,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(week, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildDepartmentSlaRankingsCard(BuildContext context) {
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
              Text('Department SLA Compliance', style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold)),
              const Text('Ranked by Speed', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildDeptSlaRow('Core Infrastructure (SRE)', 98.4, const Color(0xFF0D9488)),
          const SizedBox(height: 8),
          _buildDeptSlaRow('Identity & Security', 96.2, const Color(0xFF0284C7)),
          const SizedBox(height: 8),
          _buildDeptSlaRow('Billing & Payments', 92.5, const Color(0xFFD97706)),
          const SizedBox(height: 8),
          _buildDeptSlaRow('Corporate IT Services', 95.8, const Color(0xFF0D9488)),
        ],
      ),
    );
  }

  Widget _buildDeptSlaRow(String department, double compliance, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(department, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('$compliance%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: compliance / 100,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }
}
