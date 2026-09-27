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
import '../../copilot/data/copilot_api.dart';
import '../../copilot/domain/copilot_model.dart';

/// SCR-09: AI Copilot Smart Drafter Screen
/// Context-aware multi-modal AI operator assistant with root-cause hypothesis cards,
/// source citations, customer response smart drafter, fast action chips, and query composer.
class AiCopilotSmartDrafterScreen extends ConsumerStatefulWidget {
  final String caseId;

  const AiCopilotSmartDrafterScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<AiCopilotSmartDrafterScreen> createState() => _AiCopilotSmartDrafterScreenState();
}

class _AiCopilotSmartDrafterScreenState extends ConsumerState<AiCopilotSmartDrafterScreen> {
  final TextEditingController _queryController = TextEditingController();
  final CopilotApi _copilotApi = CopilotApi();

  CaseModel? _caseDetail;
  AiAnalysisModel? _aiAnalysis;
  String _draftText =
      "We have identified intermittent packet drop during Okta token validation on ingress pod-04. Traffic has been successfully rerouted to standby pod-02 while the active cache configuration is safely remediated.";
  String _lastOperatorQuery = 'What is the current hypothesis on the Envoy 504 gateway spike, and what should we tell the customer?';
  List<CopilotCitationModel> _citations = [];
  bool _isLoading = false;
  bool _isDrafterLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCopilotContext();
  }

  Future<void> _loadCopilotContext() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final caseId = widget.caseId;
    final results = await Future.wait([
      CaseRepository().getCaseDetail(caseId),
      CaseRepository().getAiAnalysis(caseId),
    ]);

    final caseRes = results[0] as dynamic;
    final aiRes = results[1] as dynamic;

    if (mounted) {
      if (caseRes.success && caseRes.data != null) {
        setState(() {
          _caseDetail = caseRes.data as CaseModel;
          _aiAnalysis = aiRes.success && aiRes.data != null ? (aiRes.data as AiAnalysisModel) : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = caseRes.error ?? 'Failed to load case context for AI Copilot';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendQuery(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _lastOperatorQuery = query.trim();
      _isDrafterLoading = true;
    });
    _queryController.clear();

    final res = await _copilotApi.queryCopilot(
      caseId: widget.caseId,
      query: _lastOperatorQuery,
    );

    if (mounted) {
      setState(() {
        _isDrafterLoading = false;
        if (res.success && res.data != null) {
          _draftText = res.data!.answer;
          _citations = res.data!.citations;
          _showFeedbackToast('Copilot synthesized intelligence', Icons.auto_awesome, const Color(0xFF7C3AED));
        } else {
          _showFeedbackToast(res.error ?? 'Copilot query failed', Icons.error_outline, const Color(0xFFE11D48));
        }
      });
    }
  }

  Future<void> _generateDraft({String audience = 'CUSTOMER', String tone = 'TECHNICAL_POLITE'}) async {
    setState(() {
      _isDrafterLoading = true;
    });

    final res = await _copilotApi.draftCommunication(
      caseId: widget.caseId,
      audience: audience,
      tone: tone,
    );

    if (mounted) {
      setState(() {
        _isDrafterLoading = false;
        if (res.success && res.data != null) {
          _draftText = res.data!.draftText;
          _showFeedbackToast('Generated $tone response draft', Icons.mark_chat_read, const Color(0xFF0D9488));
        } else {
          _showFeedbackToast(res.error ?? 'Draft generation failed', Icons.error_outline, const Color(0xFFE11D48));
        }
      });
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
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
      currentPath: '/dashboard/operator',
      title: 'AI Copilot Drafter',
      child: _isLoading
          ? const NexusLoadingView(message: 'Initializing Nexus AI Copilot & case context...')
          : _errorMessage != null
              ? NexusErrorView(
                  message: _errorMessage!,
                  onRetry: _loadCopilotContext,
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
          _buildContextUnderlay(),
          const SizedBox(height: AppSpacing.sm),
          _buildSyncPulseBanner(),
          const SizedBox(height: AppSpacing.sm),
          _buildFastActionChips(),
          const SizedBox(height: AppSpacing.md),
          _buildOperatorQueryBubble(),
          const SizedBox(height: AppSpacing.sm),
          _buildAiAnalysisCard(),
          const SizedBox(height: AppSpacing.md),
          _buildSmartDrafterCard(),
          const SizedBox(height: AppSpacing.md),
          _buildBottomInputBar(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1080),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildContextUnderlay(),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSyncPulseBanner(),
                        const SizedBox(height: AppSpacing.sm),
                        _buildFastActionChips(),
                        const SizedBox(height: AppSpacing.md),
                        _buildOperatorQueryBubble(),
                        const SizedBox(height: AppSpacing.sm),
                        _buildAiAnalysisCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSmartDrafterCard(),
                        const SizedBox(height: AppSpacing.md),
                        _buildBottomInputBar(),
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

  Widget _buildContextUnderlay() {
    final caseNum = _caseDetail?.caseNumber ?? widget.caseId;
    final priority = _caseDetail?.priority ?? 'CRITICAL';
    final title = _caseDetail?.title ?? 'Envoy 504 Gateway Spike across us-east-prod';
    final description = _caseDetail?.description ??
        'Cluster telemetry alerts downstream timeouts reaching ingress edge layer. Error budget burn rate 14.8x.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFFE4E6), borderRadius: BorderRadius.circular(8)),
                    child: Text('${_caseDetail?.severity ?? "P1"} $priority',
                        style: const TextStyle(color: Color(0xFFE11D48), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    caseNum.length > 16 ? 'NEX-${caseNum.substring(0, 8).toUpperCase()}' : caseNum,
                    style: AppTypography.codeSmall(context).copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Text(
                _caseDetail?.slaRiskLevel == 'BREACHED'
                    ? 'SLA: BREACHED'
                    : 'SLA: ${_caseDetail?.slaRiskLevel ?? "Active"}',
                style: const TextStyle(
                    color: Color(0xFFE11D48), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Text(description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSyncPulseBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.cloud_done, size: 14, color: Color(0xFF4648D4)),
              SizedBox(width: 6),
              Text('CONTEXT SYNCED',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.8)),
            ],
          ),
          Text('LIVE STREAM',
              style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'JetBrains Mono')),
        ],
      ),
    );
  }

  Widget _buildFastActionChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildActionChip(Icons.summarize, 'Summarize Blockers', const Color(0xFF6366F1),
              onTap: () => _sendQuery('Summarize current blocker root cause and resolution status.')),
          const SizedBox(width: AppSpacing.xs),
          _buildActionChip(Icons.edit_note, 'Draft Customer Update', const Color(0xFF7C3AED), isPurple: true,
              onTap: () => _generateDraft(audience: 'CUSTOMER', tone: 'TECHNICAL_POLITE')),
          const SizedBox(width: AppSpacing.xs),
          _buildActionChip(Icons.troubleshoot, 'Analyze Root-Cause', const Color(0xFF006194),
              onTap: () => _sendQuery('Perform automated diagnostic root-cause breakdown.')),
          const SizedBox(width: AppSpacing.xs),
          _buildActionChip(Icons.timer, 'Check SLA Risk', const Color(0xFFEA580C),
              onTap: () => _sendQuery('Calculate SLA breach trajectory and escalation needs.')),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, Color iconColor, {bool isPurple = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap ?? () => _showFeedbackToast('Copilot triggered: $label', icon, isPurple ? const Color(0xFF7C3AED) : AppColors.primary),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isPurple ? const Color(0xFFFAF5FF) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPurple ? const Color(0xFFC084FC).withValues(alpha: 0.4) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isPurple ? const Color(0xFF7C3AED) : AppColors.textPrimary,
                fontSize: 11,
                fontWeight: isPurple ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOperatorQueryBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 32),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: const BoxDecoration(
          color: Color(0xFF4648D4),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
            topRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${_caseDetail?.assignedToName ?? "Operator"} (Query)',
                    style: const TextStyle(color: Color(0xFFE1E0FF), fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              _lastOperatorQuery,
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.35),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAnalysisCard() {
    final confidence = (_aiAnalysis?.confidenceScore != null)
        ? '${(_aiAnalysis!.confidenceScore! * 100).toInt()}% Match'
        : '96% Match';
    final summary = _aiAnalysis?.executiveSummary ??
        'Cluster node us-east-prod-04 hit memory ceiling at 98.4%, causing evictions of active user sessions and cascading timeouts.';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
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
                  Icon(Icons.tune, size: 16, color: Color(0xFF7C3AED)),
                  SizedBox(width: 4),
                  Text('NEXUS ANALYSIS',
                      style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.8)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(8)),
                child: Text(confidence,
                    style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildHypothesisTile(
            icon: Icons.memory,
            iconColor: const Color(0xFFD97706),
            title: 'Primary Hypothesis: Cache & Buffer Exhaustion',
            desc: summary,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildHypothesisTile(
            icon: Icons.hourglass_bottom,
            iconColor: const Color(0xFFE11D48),
            title: 'Cascading Handshake Delays',
            desc: 'Downstream SSO token verification timing out at the hard ceiling, saturating connection pools.',
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              const Text('SOURCES:', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold)),
              if (_citations.isNotEmpty)
                ..._citations.map((c) => _buildSourceChip(c.sourceTitle))
              else ...[
                _buildSourceChip('Telemetry Stream'),
                _buildSourceChip('Envoy Pod Metrics'),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHypothesisTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 2),
          Text(desc, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildSourceChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: const Color(0xFFE2E7FF), borderRadius: BorderRadius.circular(6)),
      child: Text(label,
          style: const TextStyle(color: Color(0xFF131B2E), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
    );
  }

  Widget _buildSmartDrafterCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
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
              const Row(
                children: [
                  Icon(Icons.mark_chat_read, size: 16, color: Color(0xFF4648D4)),
                  SizedBox(width: 6),
                  Text('Smart Drafter: Customer Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(8)),
                child: const Text('Polite & Technical',
                    style: TextStyle(color: Color(0xFF0284C7), fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isDrafterLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          SizedBox(width: 8),
                          Text('Synthesizing draft response...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  )
                else ...[
                  Text(
                    '“$_draftText”',
                    style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('${_draftText.length} chars • AI Generated',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'JetBrains Mono')),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                flex: 6,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showFeedbackToast('Draft inserted into response thread', Icons.arrow_forward, const Color(0xFF0D9488));
                    context.push('/cases/${widget.caseId}/investigation');
                  },
                  icon: const Icon(Icons.arrow_forward, size: 14, color: Colors.white),
                  label: const Text('Insert in Reply',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4648D4),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _generateDraft(audience: 'CUSTOMER', tone: 'EXECUTIVE_BRIEF'),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Brief', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showFeedbackToast('Copied draft to clipboard', Icons.content_copy, AppColors.primary),
                  icon: const Icon(Icons.content_copy, size: 14),
                  label: const Text('Copy', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showFeedbackToast('Telemetry file attach dialog', Icons.attach_file, AppColors.primary),
            icon: const Icon(Icons.attach_file, size: 18, color: AppColors.textSecondary),
          ),
          Expanded(
            child: TextField(
              controller: _queryController,
              onSubmitted: _sendQuery,
              style: AppTypography.bodySmall(context),
              decoration: const InputDecoration(
                hintText: 'Ask Copilot or request action...',
                hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showFeedbackToast('Voice dictation active', Icons.mic, const Color(0xFF0D9488)),
            icon: const Icon(Icons.mic, size: 18, color: AppColors.textSecondary),
          ),
          InkWell(
            onTap: () => _sendQuery(_queryController.text),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(color: const Color(0xFF4648D4), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.arrow_upward, size: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
