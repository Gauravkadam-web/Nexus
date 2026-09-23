import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../../case/data/case_repository.dart';
import '../../case/domain/case_model.dart';
import '../../resolution/data/resolution_api.dart';
import '../../resolution/domain/resolution_model.dart';

/// SCR-10: Resolution Proposal & Closure Modal Screen
/// Dual-signoff resolution workspace with AI Root Cause Digest, remediation classification pills,
/// customer-facing closure notes, KEDB publication toggle, and stabilization verification gates.
class ResolutionProposalClosureScreen extends ConsumerStatefulWidget {
  final String caseId;

  const ResolutionProposalClosureScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<ResolutionProposalClosureScreen> createState() => _ResolutionProposalClosureScreenState();
}

class _ResolutionProposalClosureScreenState extends ConsumerState<ResolutionProposalClosureScreen> {
  final TextEditingController _noteController = TextEditingController(
    text: "Ingress Envoy connection limits have been re-calibrated. All affected regional pods have returned to nominal latency (<12ms).",
  );
  final ResolutionApi _resolutionApi = ResolutionApi();

  CaseModel? _caseDetail;
  ResolutionModel? _existingProposal;
  bool _includeRcaSummary = true;
  bool _publishToKedb = true;
  String _selectedRemediation = 'Permanent Patch';
  bool _isLoading = false;
  bool _isDispatching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResolutionContext();
  }

  Future<void> _loadResolutionContext() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final caseId = widget.caseId;
    final results = await Future.wait([
      CaseRepository().getCaseDetail(caseId),
      _resolutionApi.getProposal(caseId),
    ]);

    final caseRes = results[0] as dynamic;
    final propRes = results[1] as dynamic;

    if (mounted) {
      if (caseRes.success && caseRes.data != null) {
        final caseData = caseRes.data as CaseModel;
        final proposal = propRes.success && propRes.data != null ? (propRes.data as ResolutionModel) : null;

        setState(() {
          _caseDetail = caseData;
          _existingProposal = proposal;
          if (proposal != null && proposal.summary.isNotEmpty) {
            _noteController.text = proposal.summary;
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = caseRes.error ?? 'Failed to load resolution context';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
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

  Future<void> _triggerHandshake() async {
    setState(() {
      _isDispatching = true;
    });

    final res = await _resolutionApi.proposeResolution(
      caseId: widget.caseId,
      summary: _noteController.text.trim(),
      rootCause: 'Connection Pool Exhaustion during burst traffic',
      resolutionAction: _selectedRemediation,
      preventiveAction: _publishToKedb ? 'Publish to KEDB for autonomous matching' : null,
    );

    if (mounted) {
      setState(() {
        _isDispatching = false;
      });

      if (res.success) {
        _showFeedbackToast('Resolution proposal dispatched to requester for sign-off', Icons.verified, const Color(0xFF0D9488));
        context.push('/cases/${widget.caseId}/track');
      } else {
        _showFeedbackToast(res.error ?? 'Failed to submit resolution', Icons.error_outline, const Color(0xFFE11D48));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/dashboard/operator',
      title: 'Propose Resolution',
      child: _isLoading
          ? const NexusLoadingView(message: 'Loading resolution verification gates...')
          : _errorMessage != null
              ? NexusErrorView(
                  message: _errorMessage!,
                  onRetry: _loadResolutionContext,
                )
              : ResponsiveLayout(
                  mobileBody: _buildMobileBody(context),
                  desktopBody: _buildDesktopBody(context),
                ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetaHeaderCard(),
          const SizedBox(height: AppSpacing.md),
          _buildAiRcaDigestCard(),
          const SizedBox(height: AppSpacing.md),
          _buildClassificationForm(),
          const SizedBox(height: AppSpacing.md),
          _buildCustomerNoteInput(),
          const SizedBox(height: AppSpacing.md),
          _buildKedbToggle(),
          const SizedBox(height: AppSpacing.md),
          _buildStabilizationGates(),
          const SizedBox(height: AppSpacing.lg),
          _buildActionFooter(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 960),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetaHeaderCard(),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildAiRcaDigestCard(),
                        const SizedBox(height: AppSpacing.md),
                        _buildClassificationForm(),
                        const SizedBox(height: AppSpacing.md),
                        _buildCustomerNoteInput(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildKedbToggle(),
                        const SizedBox(height: AppSpacing.md),
                        _buildStabilizationGates(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildActionFooter(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaHeaderCard() {
    final caseNum = _caseDetail?.id ?? widget.caseId;
    final title = _caseDetail?.title ?? 'Authentication Gateway Timeout during SSO';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 6,
            offset: Offset(0, 2),
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
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(6)),
                child: Text(caseNum, style: AppTypography.codeSmall(context).copyWith(fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(10)),
                child: Text(
                  _existingProposal != null ? 'Status: ${_existingProposal!.status}' : 'Ready for Handshake',
                  style: const TextStyle(color: Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Propose Resolution & Close Case',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            '“$title” — verified system stabilization.',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRcaDigestCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: Color(0xFF831ADA)),
                  SizedBox(width: 4),
                  Text('NEXUS COPILOT ROOT-CAUSE',
                      style: TextStyle(color: Color(0xFF831ADA), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
                ],
              ),
              Text('Model v4.2',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'JetBrains Mono')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Redis token cache exhaustion mitigated by hotpatch #4099. Connection pool limits expanded from 1024 to 4096. Error budget recovered to 99.98%.',
            style: TextStyle(fontSize: 12, height: 1.35, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: () {
              setState(() {
                _includeRcaSummary = !_includeRcaSummary;
              });
            },
            child: Row(
              children: [
                Checkbox(
                  value: _includeRcaSummary,
                  onChanged: (val) {
                    setState(() {
                      _includeRcaSummary = val ?? true;
                    });
                  },
                  activeColor: const Color(0xFF4648D4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Expanded(
                  child: Text('Include AI automated RCA summary in customer closure notice',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassificationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ROOT CAUSE CATEGORY',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${_caseDetail?.categoryName ?? "Infrastructure"} > Connection Pool Exhaustion',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const Icon(Icons.expand_more, size: 18, color: AppColors.textSecondary),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text('REMEDIATION CLASSIFICATION',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              _buildPill('Workaround'),
              _buildPill('Permanent Patch'),
              _buildPill('Config Rollback'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPill(String title) {
    final isSelected = _selectedRemediation == title;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRemediation = title;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4)] : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4648D4) : AppColors.textSecondary,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerNoteInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('CUSTOMER-FACING NOTE',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            Text('Dual Audited', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F3FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _noteController,
            maxLines: 3,
            style: AppTypography.bodySmall(context),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(AppSpacing.sm),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKedbToggle() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _publishToKedb = !_publishToKedb;
          });
        },
        child: Row(
          children: [
            Checkbox(
              value: _publishToKedb,
              onChanged: (val) {
                setState(() {
                  _publishToKedb = val ?? true;
                });
              },
              activeColor: const Color(0xFF4648D4),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Publish to KEDB (Known Error Database)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('Enables autonomous triage matching for incident recurrence',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStabilizationGates() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('STABILIZATION GATES',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(8)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: Color(0xFF0D9488)),
                  SizedBox(width: 6),
                  Text('Synthetic probe telemetry passing', style: TextStyle(fontSize: 11)),
                ],
              ),
              Text('100/100',
                  style: TextStyle(color: Color(0xFF0D9488), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFF2F3FF), borderRadius: BorderRadius.circular(8)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.pending, size: 16, color: Color(0xFF6366F1)),
                  SizedBox(width: 6),
                  Text('Requester dual sign-off requested', style: TextStyle(fontSize: 11)),
                ],
              ),
              Text(
                _existingProposal?.status ?? 'PENDING',
                style: const TextStyle(color: Color(0xFF6366F1), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionFooter() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: _isDispatching ? null : _triggerHandshake,
            icon: _isDispatching
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.verified, size: 16, color: Colors.white),
            label: Text(
              _isDispatching ? 'Dispatching Handshake...' : 'Submit Resolution to Requester',
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () => _showFeedbackToast('Case flagged: 24h Telemetry Monitoring', Icons.monitor_heart, AppColors.primary),
              child: const Text('Keep Open in Monitoring Mode', style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFFE11D48), fontSize: 11)),
            ),
          ],
        ),
      ],
    );
  }
}
