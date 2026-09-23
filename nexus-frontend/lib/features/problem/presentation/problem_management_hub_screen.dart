import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../data/problem_api.dart';
import '../domain/problem_model.dart';

/// SCR-13: Problem Management & Root Cause Hub Screen
/// ITIL v4 KEDB knowledge engine featuring autonomous AI vector anomaly clustering,
/// master problem records, linked incident graphs, and 5-Whys root-cause tracking.
class ProblemManagementHubScreen extends ConsumerStatefulWidget {
  const ProblemManagementHubScreen({super.key});

  @override
  ConsumerState<ProblemManagementHubScreen> createState() => _ProblemManagementHubScreenState();
}

class _ProblemManagementHubScreenState extends ConsumerState<ProblemManagementHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<ProblemModel> _problems = [];
  List<RecurringPatternModel> _patterns = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      ProblemApi().getProblems(),
      ProblemApi().getRecurringPatterns(),
    ]);

    final probRes = results[0] as dynamic;
    final patRes = results[1] as dynamic;

    if (mounted) {
      if (probRes.success && probRes.data != null) {
        setState(() {
          _problems = probRes.data as List<ProblemModel>;
          _patterns = patRes.success && patRes.data != null ? (patRes.data as List<RecurringPatternModel>) : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = probRes.error ?? 'Failed to load problem management data';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      currentPath: '/problems',
      title: 'Problem Management Hub',
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
          _buildKedbHeaderStrip(context),
          const SizedBox(height: AppSpacing.sm),
          _buildKpiMetricsGrid(context),
          const SizedBox(height: AppSpacing.sm),
          _buildAiVectorAnomalyCard(context),
          const SizedBox(height: AppSpacing.sm),
          _buildMasterProblemsSection(context),
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
          _buildKedbHeaderStrip(context),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _buildKpiMetricsGrid(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildAiVectorAnomalyCard(context),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 7,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMasterProblemsSection(context),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKedbHeaderStrip(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sync, size: 12, color: Color(0xFF7C3AED)),
                    SizedBox(width: 4),
                    Text(
                      'ITIL v4 KEDB Synced',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF7C3AED)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Vector Space Active',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF0D9488),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMetricsGrid(BuildContext context) {
    final activeCount = _problems.length;
    final totalLinked = _problems.fold<int>(0, (sum, p) => sum + p.incidentCount);

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
            _buildKpiCard(
              title: 'ACTIVE PROBLEMS',
              value: '$activeCount',
              badgeText: 'ITIL v4',
              badgeColor: const Color(0xFFD97706),
              badgeBg: const Color(0xFFFEF3C7),
              icon: Icons.psychology_outlined,
            ),
            _buildKpiCard(
              title: 'LINKED INCIDENTS',
              value: '$totalLinked',
              badgeText: 'Cross-Domain',
              badgeColor: const Color(0xFF0D9488),
              badgeBg: const Color(0xFFCCFBF1),
              icon: Icons.hub_outlined,
            ),
            _buildKpiCard(
              title: 'AI PATTERNS',
              value: '${_patterns.length}',
              badgeText: 'Vector Space',
              badgeColor: const Color(0xFF9333EA),
              badgeBg: const Color(0xFFFAF5FF),
              icon: Icons.auto_awesome,
            ),
            _buildKpiCard(
              title: 'AVG RCA TIME',
              value: '1.8d',
              badgeText: 'Target <3.0d',
              badgeColor: const Color(0xFF6366F1),
              badgeBg: const Color(0xFFEEF2FF),
              icon: Icons.timer_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
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
                fontWeight: FontWeight.w600,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiVectorAnomalyCard(BuildContext context) {
    if (_patterns.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFFFAF5FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.3)),
        ),
        child: const Text('No active recurring pattern anomalies detected in vector embeddings.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      );
    }

    final topPattern = _patterns.first;
    final similarityPct = (topPattern.similarityScore > 1 ? topPattern.similarityScore : topPattern.similarityScore * 100).toStringAsFixed(1);

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
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    topPattern.clusterName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('$similarityPct% Match', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF9333EA))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${topPattern.caseCount} incidents identified in vector space sharing ${topPattern.primaryCategory} operational signatures.',
            style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          if (topPattern.sampleCaseTitles.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: topPattern.sampleCaseTitles.map((t) => _buildCasePill(t)).toList(),
            ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF9333EA),
                  side: const BorderSide(color: Color(0xFFC084FC)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.bubble_chart_outlined, size: 14),
                label: const Text('Inspect Vector', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () => _showFeedbackToast('Vector distance graph rendered in 3D canvas', Icons.scatter_plot, const Color(0xFF9333EA)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCasePill(String caseId) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Text(
        caseId,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.accentPrimary, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildMasterProblemsSection(BuildContext context) {
    if (_isLoading) {
      return const NexusLoadingView(message: 'Loading master problem records & root causes...');
    }
    if (_errorMessage != null) {
      return NexusErrorView(message: _errorMessage!, onRetry: _loadData);
    }
    if (_problems.isEmpty) {
      return const NexusEmptyView(
        title: 'No Master Problems Found',
        message: 'No active problem records or linked incidents found.',
        icon: Icons.psychology_outlined,
      );
    }

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
                'Master Problem Records',
                style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_problems.length} Active Records',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._problems.map((p) {
            final shortId = p.id.length > 8 ? p.id.substring(0, 8).toUpperCase() : p.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildProblemRecordCard(
                problemId: 'PRB-$shortId',
                title: p.title,
                category: 'Operational Problem',
                severity: p.status,
                linkedIncidentsCount: p.incidentCount,
                kedbStatus: p.status.replaceAll('_', ' '),
                rootCause: p.rootCause ?? p.description,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProblemRecordCard({
    required String problemId,
    required String title,
    required String category,
    required String severity,
    required int linkedIncidentsCount,
    required String kedbStatus,
    required String rootCause,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
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
                  Text(
                    problemId,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.accentPrimary),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.accentPrimary),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFCCFBF1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  kedbStatus,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Root Cause: $rootCause',
            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.hub_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '$linkedIncidentsCount Linked Incidents',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                  ),
                ],
              ),
              InkWell(
                onTap: () => _showFeedbackToast('Opening RCA Investigation Studio for $problemId', Icons.open_in_new, AppColors.accentPrimary),
                child: const Text(
                  'View RCA Studio ↗',
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
