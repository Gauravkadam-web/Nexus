import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../data/admin_api.dart';
import '../domain/admin_models.dart';

/// SCR-16: Admin SLA Policy & Escalation Rule Builder Screen
/// Dynamic SLA policy engine configuration, multi-tier matrix (P1-P4),
/// breach notification rules, and AI automated threshold optimization.
class AdminSlaPolicyBuilderScreen extends ConsumerStatefulWidget {
  const AdminSlaPolicyBuilderScreen({super.key});

  @override
  ConsumerState<AdminSlaPolicyBuilderScreen> createState() => _AdminSlaPolicyBuilderScreenState();
}

class _AdminSlaPolicyBuilderScreenState extends ConsumerState<AdminSlaPolicyBuilderScreen> {
  bool _isBufferApplied = false;
  List<SlaPolicyModel> _policies = [];
  List<EscalationRuleModel> _rules = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPolicies();
  }

  Future<void> _loadPolicies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final results = await Future.wait([
      AdminApi().getSlaPolicies(),
      AdminApi().getEscalationRules(),
    ]);

    final polRes = results[0] as dynamic;
    final ruleRes = results[1] as dynamic;

    if (mounted) {
      if (polRes.success && polRes.data != null) {
        setState(() {
          _policies = polRes.data as List<SlaPolicyModel>;
          _rules = ruleRes.success && ruleRes.data != null ? (ruleRes.data as List<EscalationRuleModel>) : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = polRes.error ?? 'Failed to load SLA policies';
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
      currentPath: '/admin/policies',
      title: 'SLA Policy Engine',
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
          _buildPolicyHeaderActions(context),
          const SizedBox(height: AppSpacing.sm),
          if (!_isBufferApplied) ...[
            _buildAiPolicyOptimizerBanner(context),
            const SizedBox(height: AppSpacing.sm),
          ],
          _buildSlaMatrixSection(context),
          const SizedBox(height: AppSpacing.sm),
          _buildEscalationChainSection(context),
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
          _buildPolicyHeaderActions(context),
          const SizedBox(height: AppSpacing.md),
          if (!_isBufferApplied) ...[
            _buildAiPolicyOptimizerBanner(context),
            const SizedBox(height: AppSpacing.md),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 7,
                child: _buildSlaMatrixSection(context),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 5,
                child: _buildEscalationChainSection(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyHeaderActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Admin SLA Policies & Rules',
              style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Configure thresholds & on-call rules',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 14),
          label: const Text('+ New Policy', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          onPressed: () => _showFeedbackToast('Opening New SLA Policy Wizard', Icons.add_circle, AppColors.accentPrimary),
        ),
      ],
    );
  }

  Widget _buildAiPolicyOptimizerBanner(BuildContext context) {
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
                    'AI Policy Optimizer',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9333EA)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('92% Breach Spike', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFE11D48))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Telemetry indicates 92% of P1 SSO cases breach during APAC handoff (03:00-05:30 UTC). Proactive recommendation: Extend standby buffer by +15 mins.',
            style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: const Text('Apply Buffer (+15m)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                onPressed: () {
                  setState(() => _isBufferApplied = true);
                  _showFeedbackToast('APAC standby buffer extended by +15 mins', Icons.check_circle, const Color(0xFF0D9488));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSlaMatrixSection(BuildContext context) {
    if (_isLoading) {
      return const NexusLoadingView(message: 'Loading SLA policies & breach matrix...');
    }
    if (_errorMessage != null) {
      return NexusErrorView(message: _errorMessage!, onRetry: _loadPolicies);
    }
    if (_policies.isEmpty) {
      return const NexusEmptyView(
        title: 'No SLA Policies Found',
        message: 'No SLA policies have been configured for this organization.',
        icon: Icons.policy_outlined,
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
              Text('Operational SLA Matrix', style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold)),
              Text('${_policies.length} Policies Configured', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._policies.map((p) {
            Color pColor = const Color(0xFF0284C7);
            Color pBg = const Color(0xFFE0F2FE);
            final pUpper = p.priority.toUpperCase();
            if (pUpper.contains('CRITICAL') || pUpper == 'P1') {
              pColor = const Color(0xFFE11D48);
              pBg = const Color(0xFFFFE4E6);
            } else if (pUpper.contains('HIGH') || pUpper == 'P2') {
              pColor = const Color(0xFFD97706);
              pBg = const Color(0xFFFEF3C7);
            }

            final firstTouchStr = '${p.responseTimeMinutes} mins';
            final resHours = (p.resolutionTimeMinutes / 60).toStringAsFixed(0);
            final resStr = '$resHours hours (${p.resolutionTimeMinutes}m)';

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _buildSlaMatrixCard(
                priority: '${p.priority} - ${p.name}',
                scope: p.isActive ? 'Active Policy' : 'Inactive',
                firstTouch: firstTouchStr,
                resolution: resStr,
                score30d: '98.5%',
                priorityColor: pColor,
                priorityBg: pBg,
                scoreColor: const Color(0xFF0D9488),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSlaMatrixCard({
    required String priority,
    required String scope,
    required String firstTouch,
    required String resolution,
    required String score30d,
    required Color priorityColor,
    required Color priorityBg,
    required Color scoreColor,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: priorityBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  priority,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: priorityColor),
                ),
              ),
              Text(scope, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('First Touch Target', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(firstTouch, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Resolution Target', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(resolution, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compliance Target', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                  Text(score30d, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: scoreColor)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEscalationChainSection(BuildContext context) {
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
          Text('Escalation Chain Flow', style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_rules.isNotEmpty)
            ..._rules.map((r) {
              Color color = const Color(0xFFD97706);
              if (r.escalateToRole.contains('MANAGER') || r.escalateToRole.contains('ADMIN')) {
                color = const Color(0xFFE11D48);
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildChainStep(
                  r.name,
                  'Trigger: ${r.triggerCondition} → Escalate to ${r.escalateToRole}',
                  color,
                ),
              );
            })
          else ...[
            _buildChainStep('Tier 1: Shift Lead Notification', 'At 75% SLA threshold (In-App + Slack)', const Color(0xFFD97706)),
            const SizedBox(height: 8),
            _buildChainStep('Tier 2: Incident Commander Bridge', 'At 90% SLA threshold (PagerDuty + Bridge)', const Color(0xFFE11D48)),
            const SizedBox(height: 8),
            _buildChainStep('Tier 3: Executive War Room', 'At 100% Breached (VP On-Call + Bridge)', const Color(0xFF7C3AED)),
          ],
        ],
      ),
    );
  }

  Widget _buildChainStep(String title, String condition, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(condition, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
