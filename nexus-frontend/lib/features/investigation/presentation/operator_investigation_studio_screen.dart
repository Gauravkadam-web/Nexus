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
import '../../collaboration/data/collaboration_api.dart';
import '../../collaboration/domain/collaboration_models.dart';
import '../data/investigation_api.dart';
import '../domain/investigation_model.dart';

/// SCR-07: Operator Investigation Studio Screen
/// Deep investigation workbench with live activity stream, AI drafter assistant,
/// telemetry latency sparkline, public/internal message composer, and tactical resolution suite.
class OperatorInvestigationStudioScreen extends ConsumerStatefulWidget {
  final String caseId;

  const OperatorInvestigationStudioScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<OperatorInvestigationStudioScreen> createState() => _OperatorInvestigationStudioScreenState();
}

class _OperatorInvestigationStudioScreenState extends ConsumerState<OperatorInvestigationStudioScreen> {
  final TextEditingController _composerController = TextEditingController();
  bool _isInternalNote = false;
  bool _isDrafterDismissed = false;
  int _selectedTab = 1; // 0: AI Triage, 1: Activity, 2: Tasks

  CaseModel? _caseDetail;
  AiAnalysisModel? _aiAnalysis;
  List<MessageModel> _messages = [];
  List<InternalNoteModel> _notes = [];
  List<InvestigationTaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _draftText =
      "We have identified packet drop during the Okta token validation stage on ingress pod-04. Traffic has been routed to standby pod-02 while we rollback.";

  @override
  void initState() {
    super.initState();
    _loadStudioData();
  }

  Future<void> _loadStudioData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final caseId = widget.caseId;
    final results = await Future.wait([
      CaseRepository().getCaseDetail(caseId),
      CaseRepository().getAiAnalysis(caseId),
      CollaborationApi().getMessages(caseId),
      CollaborationApi().getInternalNotes(caseId),
      InvestigationApi().getTasks(caseId),
    ]);

    final caseRes = results[0] as dynamic;
    final aiRes = results[1] as dynamic;
    final msgRes = results[2] as dynamic;
    final noteRes = results[3] as dynamic;
    final taskRes = results[4] as dynamic;

    if (mounted) {
      if (caseRes.success && caseRes.data != null) {
        setState(() {
          _caseDetail = caseRes.data as CaseModel;
          _aiAnalysis = aiRes.success && aiRes.data != null ? (aiRes.data as AiAnalysisModel) : null;
          _messages = msgRes.success && msgRes.data != null ? (msgRes.data as List<MessageModel>) : [];
          _notes = noteRes.success && noteRes.data != null ? (noteRes.data as List<InternalNoteModel>) : [];
          _tasks = taskRes.success && taskRes.data != null ? (taskRes.data as List<InvestigationTaskModel>) : [];
          if (_aiAnalysis != null && _aiAnalysis!.suggestedSteps.isNotEmpty) {
            _draftText = _aiAnalysis!.suggestedSteps.join(' ');
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = caseRes.error ?? 'Failed to load case investigation context';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendComposerMessage() async {
    final text = _composerController.text.trim();
    if (text.isEmpty) return;

    if (_isInternalNote) {
      final res = await CollaborationApi().addInternalNote(caseId: widget.caseId, content: text);
      if (res.success && res.data != null) {
        setState(() {
          _notes.add(res.data!);
          _composerController.clear();
        });
        _showFeedbackToast('Internal note logged', Icons.lock, const Color(0xFF0D9488));
      }
    } else {
      final res = await CollaborationApi().sendMessage(caseId: widget.caseId, content: text);
      if (res.success && res.data != null) {
        setState(() {
          _messages.add(res.data!);
          _composerController.clear();
        });
        _showFeedbackToast('Message dispatched to requester', Icons.send, const Color(0xFF0D9488));
      }
    }
  }

  @override
  void dispose() {
    _composerController.dispose();
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
      title: 'Investigation Studio',
      child: _isLoading
          ? const NexusLoadingView(message: 'Loading case investigation workbench...')
          : _errorMessage != null
              ? NexusErrorView(message: _errorMessage!, onRetry: _loadStudioData)
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
          _buildTopContextPanel(),
          const SizedBox(height: AppSpacing.sm),
          _buildSegmentedTabRail(),
          const SizedBox(height: AppSpacing.md),
          _buildLiveActivityStream(),
          const SizedBox(height: AppSpacing.md),
          if (!_isDrafterDismissed) ...[
            _buildAiDrafterCard(),
            const SizedBox(height: AppSpacing.md),
          ],
          _buildTelemetrySparkline(),
          const SizedBox(height: AppSpacing.md),
          _buildMessageComposer(),
          const SizedBox(height: AppSpacing.md),
          _buildBottomActionSuite(),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopContextPanel(),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSegmentedTabRail(),
                        const SizedBox(height: AppSpacing.md),
                        _buildLiveActivityStream(),
                        const SizedBox(height: AppSpacing.md),
                        _buildMessageComposer(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_isDrafterDismissed) ...[
                          _buildAiDrafterCard(),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        _buildTelemetrySparkline(),
                        const SizedBox(height: AppSpacing.md),
                        _buildBottomActionSuite(),
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

  Widget _buildTopContextPanel() {
    final caseNum = _caseDetail?.caseNumber ?? widget.caseId;
    final priority = _caseDetail?.priority ?? 'HIGH';
    final status = _caseDetail?.status ?? 'INVESTIGATING';
    final title = _caseDetail?.title ?? 'Case Investigation';
    final category = _caseDetail?.categoryName ?? 'System Core';

    Color pColor = const Color(0xFF0284C7);
    Color pBg = const Color(0xFFE0F2FE);
    if (priority.toUpperCase().contains('CRITICAL')) {
      pColor = const Color(0xFFE11D48);
      pBg = const Color(0xFFFFE4E6);
    } else if (priority.toUpperCase().contains('HIGH')) {
      pColor = const Color(0xFFD97706);
      pBg = const Color(0xFFFEF3C7);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
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
              Row(
                children: [
                  const Icon(Icons.terminal, size: 18, color: Color(0xFF4648D4)),
                  const SizedBox(width: 6),
                  Text(
                    caseNum,
                    style: AppTypography.codeSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: pBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: pColor,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Color(0xFFD97706),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6).withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top, size: 14, color: Color(0xFFE11D48)),
                    const SizedBox(width: 4),
                    Text(
                      'SLA Active',
                      style: AppTypography.codeSmall(context).copyWith(
                        color: const Color(0xFFE11D48),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDFF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.dns, size: 14, color: Color(0xFF006194)),
                    const SizedBox(width: 4),
                    Text(
                      category,
                      style: AppTypography.labelSmall(context).copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabRail() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildRailTab(0, '✨ AI Triage'),
          _buildRailTab(1, 'Activity (${_messages.length + _notes.length})'),
          _buildRailTab(2, 'Tasks (${_tasks.length})'),
        ],
      ),
    );
  }

  Widget _buildRailTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
          if (index == 2) {
            context.push('/cases/${widget.caseId}/collaboration');
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF4648D4) : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveActivityStream() {
    if (_messages.isEmpty && _notes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: NexusEmptyView(
          title: 'No Activity Yet',
          message: 'No messages or internal notes logged on this case.',
          icon: Icons.chat_bubble_outline,
        ),
      );
    }

    return Column(
      children: [
        ..._messages.map((m) {
          final initials = m.senderName.isNotEmpty ? m.senderName[0].toUpperCase() : 'U';
          final timeStr = '${m.createdAt.hour.toString().padLeft(2, '0')}:${m.createdAt.minute.toString().padLeft(2, '0')}';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildActivityCard(
              authorName: m.senderName,
              roleText: m.senderRole,
              timeText: timeStr,
              avatarLetter: initials,
              avatarColor: const Color(0xFF6366F1),
              content: m.content,
            ),
          );
        }),
        ..._notes.map((n) {
          final initials = n.authorName.isNotEmpty ? n.authorName[0].toUpperCase() : 'O';
          final timeStr = '${n.createdAt.hour.toString().padLeft(2, '0')}:${n.createdAt.minute.toString().padLeft(2, '0')}';
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _buildActivityCard(
              authorName: '${n.authorName} (Internal)',
              roleText: 'Internal Investigation Note',
              timeText: timeStr,
              avatarLetter: initials,
              avatarColor: const Color(0xFF831ADA),
              content: n.content,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActivityCard({
    required String authorName,
    required String roleText,
    required String timeText,
    required String avatarLetter,
    required Color avatarColor,
    required String content,
    String? attachmentName,
    String? attachmentSize,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: avatarColor.withValues(alpha: 0.15),
                child: Text(
                  avatarLetter,
                  style: TextStyle(color: avatarColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text(timeText, style: AppTypography.codeSmall(context).copyWith(color: AppColors.textMuted, fontSize: 10)),
                      ],
                    ),
                    Text(roleText, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            content,
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.textPrimary,
              height: 1.4,
              fontSize: 12,
            ),
          ),
          if (attachmentName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            InkWell(
              onTap: () => _showFeedbackToast('Downloaded $attachmentName', Icons.download, AppColors.primary),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.description, size: 14, color: Color(0xFF006194)),
                    const SizedBox(width: 6),
                    Text(attachmentName, style: AppTypography.codeSmall(context).copyWith(fontSize: 11, fontWeight: FontWeight.w600)),
                    if (attachmentSize != null) ...[
                      const SizedBox(width: 4),
                      Text('• $attachmentSize', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                    ],
                    const SizedBox(width: 6),
                    const Icon(Icons.download, size: 14, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAiDrafterCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC084FC).withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    'AI DRAFTER SUGGESTION',
                    style: AppTypography.labelSmall(context).copyWith(
                      color: const Color(0xFF831ADA),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const Text('Just now', style: TextStyle(color: AppColors.textMuted, fontSize: 10, fontFamily: 'JetBrains Mono')),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '“$_draftText”',
              style: AppTypography.bodySmall(context).copyWith(
                fontStyle: FontStyle.italic,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isDrafterDismissed = true;
                  });
                },
                child: const Text('Dismiss', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ),
              const SizedBox(width: AppSpacing.xs),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _composerController.text = _draftText;
                  });
                  _showFeedbackToast('AI Draft applied to message composer', Icons.auto_awesome, const Color(0xFF831ADA));
                },
                icon: const Text('✨', style: TextStyle(fontSize: 12)),
                label: const Text('Apply Draft', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4648D4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetrySparkline() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, size: 16, color: Color(0xFF006194)),
                  SizedBox(width: 6),
                  Text('Ingress Gateway Health', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE4E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '94.2% Latency Spike',
                  style: TextStyle(color: Color(0xFFE11D48), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Custom Sparkline Painter Simulation
          Container(
            height: 48,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF4648D4).withValues(alpha: 0.08), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              painter: _SparklinePainter(),
            ),
          ),
          const SizedBox(height: 4),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('10:00 (Canary)', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'JetBrains Mono')),
              Text('10:15 (Degraded)', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'JetBrains Mono')),
              Text('10:28 (Now)', style: TextStyle(color: Color(0xFFE11D48), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isInternalNote = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: !_isInternalNote ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: !_isInternalNote
                              ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 2)]
                              : null,
                        ),
                        child: const Text('Public Message', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _isInternalNote = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _isInternalNote ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: _isInternalNote
                              ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 2)]
                              : null,
                        ),
                        child: const Row(
                          children: [
                            Text('Internal Note', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            SizedBox(width: 3),
                            Icon(Icons.lock, size: 10, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0D9488),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text('TLS 1.3', style: TextStyle(color: AppColors.textMuted, fontSize: 9, fontFamily: 'JetBrains Mono')),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _composerController,
              maxLines: 3,
              style: AppTypography.bodySmall(context),
              decoration: InputDecoration(
                hintText: _isInternalNote
                    ? 'Write internal operator note (Hidden from requester)...'
                    : 'Type an update to Sarah Jenkins...',
                hintStyle: AppTypography.bodySmall(context).copyWith(color: AppColors.textMuted, fontSize: 12),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(AppSpacing.sm),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showFeedbackToast('Attachment dialogue opened', Icons.attach_file, AppColors.primary),
                    icon: const Icon(Icons.attach_file, size: 18, color: AppColors.textSecondary),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    onPressed: () => _showFeedbackToast('Code block template inserted', Icons.code, AppColors.primary),
                    icon: const Icon(Icons.code, size: 18, color: AppColors.textSecondary),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _composerController.text = _draftText;
                      });
                      _showFeedbackToast('AI Copilot generated completion', Icons.auto_awesome, const Color(0xFF831ADA));
                    },
                    icon: const Icon(Icons.auto_awesome, size: 18, color: Color(0xFF831ADA)),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _sendComposerMessage,
                icon: const Icon(Icons.send, size: 12, color: Colors.white),
                label: const Text('Send', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4648D4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionSuite() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/cases/${widget.caseId}/collaboration');
            },
            icon: const Icon(Icons.task_alt, size: 16, color: Color(0xFF0D9488)),
            label: const Text('Evidence & Tasks', style: TextStyle(color: Color(0xFF0D9488), fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCCFBF1),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              _showFeedbackToast('Tier-3 Incident Manager alerted', Icons.arrow_upward, const Color(0xFFE11D48));
            },
            icon: const Icon(Icons.arrow_upward, size: 16, color: Color(0xFFE11D48)),
            label: const Text('Escalate Tier-3', style: TextStyle(color: Color(0xFFE11D48), fontSize: 11, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFE4E6),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }


}

/// Custom Sparkline Painter for telemetry latency spikes
class _SparklinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4648D4)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFFE11D48)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.4, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.7, size.width * 0.75, size.height * 0.15);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.1, size.width * 0.95, size.height * 0.35);

    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.15), 3.5, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
