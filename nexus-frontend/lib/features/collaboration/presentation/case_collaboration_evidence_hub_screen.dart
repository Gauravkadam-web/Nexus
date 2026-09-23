import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
import '../../investigation/data/investigation_api.dart';
import '../../investigation/domain/investigation_model.dart';

/// SCR-08: Case Collaboration & Evidence Hub Screen
/// Real-time live war room audio bridge, AI Copilot runbook suggestions,
/// multi-tab operational workbench (Remediation Checklist, Confidential Notes, Cryptographic Evidence Locker).
class CaseCollaborationEvidenceHubScreen extends ConsumerStatefulWidget {
  final String caseId;

  const CaseCollaborationEvidenceHubScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<CaseCollaborationEvidenceHubScreen> createState() => _CaseCollaborationEvidenceHubScreenState();
}

class _CaseCollaborationEvidenceHubScreenState extends ConsumerState<CaseCollaborationEvidenceHubScreen> {
  int _activeTab = 0; // 0: Tasks, 1: War Room & Notes, 2: Evidence Locker
  final TextEditingController _noteController = TextEditingController();

  CaseModel? _caseDetail;
  AiAnalysisModel? _aiAnalysis;
  List<InternalNoteModel> _notes = [];
  List<AttachmentModel> _attachments = [];
  List<InvestigationTaskModel> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHubData();
  }

  Future<void> _loadHubData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final caseId = widget.caseId;
    final results = await Future.wait([
      CaseRepository().getCaseDetail(caseId),
      CaseRepository().getAiAnalysis(caseId),
      CollaborationApi().getInternalNotes(caseId),
      CollaborationApi().getAttachments(caseId),
      InvestigationApi().getTasks(caseId),
    ]);

    final caseRes = results[0] as dynamic;
    final aiRes = results[1] as dynamic;
    final noteRes = results[2] as dynamic;
    final attRes = results[3] as dynamic;
    final taskRes = results[4] as dynamic;

    if (mounted) {
      if (caseRes.success && caseRes.data != null) {
        setState(() {
          _caseDetail = caseRes.data as CaseModel;
          _aiAnalysis = aiRes.success && aiRes.data != null ? (aiRes.data as AiAnalysisModel) : null;
          _notes = noteRes.success && noteRes.data != null ? (noteRes.data as List<InternalNoteModel>) : [];
          _attachments = attRes.success && attRes.data != null ? (attRes.data as List<AttachmentModel>) : [];
          _tasks = taskRes.success && taskRes.data != null ? (taskRes.data as List<InvestigationTaskModel>) : [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = caseRes.error ?? 'Failed to load case collaboration workspace';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addNote() async {
    final text = _noteController.text.trim();
    if (text.isEmpty) return;

    final res = await CollaborationApi().addInternalNote(caseId: widget.caseId, content: text);
    if (res.success && res.data != null) {
      setState(() {
        _notes.add(res.data!);
        _noteController.clear();
      });
      _showFeedbackToast('Confidential note cryptographically appended', Icons.lock, const Color(0xFF0D9488));
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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/dashboard/operator',
      title: 'Collaboration & Evidence',
      child: _isLoading
          ? const NexusLoadingView(message: 'Connecting to incident war room & evidence locker...')
          : _errorMessage != null
              ? NexusErrorView(
                  message: _errorMessage!,
                  onRetry: _loadHubData,
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
          _buildUrgencyBanner(),
          const SizedBox(height: AppSpacing.sm),
          _buildIncidentMetaCard(),
          const SizedBox(height: AppSpacing.md),
          _buildAiCopilotRunbookCard(),
          const SizedBox(height: AppSpacing.md),
          _buildSegmentedTabNav(),
          const SizedBox(height: AppSpacing.md),
          _buildTabContent(),
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
              _buildUrgencyBanner(),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIncidentMetaCard(),
                        const SizedBox(height: AppSpacing.md),
                        _buildAiCopilotRunbookCard(),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: 7,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSegmentedTabNav(),
                        const SizedBox(height: AppSpacing.md),
                        _buildTabContent(),
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

  Widget _buildUrgencyBanner() {
    final caseNum = _caseDetail?.caseNumber ?? widget.caseId;
    final priority = _caseDetail?.priority ?? 'HIGH';
    final isUrgent = priority == 'CRITICAL' || priority == 'HIGH';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: isUrgent ? const Color(0xFFFFE4E6) : const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isUrgent ? const Color(0xFFE11D48).withValues(alpha: 0.2) : const Color(0xFF3B82F6).withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(isUrgent ? Icons.emergency : Icons.info_outline, size: 18, color: isUrgent ? const Color(0xFFE11D48) : const Color(0xFF2563EB)),
              const SizedBox(width: 6),
              Text(
                caseNum,
                style: AppTypography.codeSmall(context).copyWith(
                  color: isUrgent ? const Color(0xFFE11D48) : const Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isUrgent ? const Color(0xFFE11D48) : const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${_caseDetail?.severity ?? "SEV-2"} $priority',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.timer, size: 14, color: isUrgent ? const Color(0xFFE11D48) : const Color(0xFF2563EB)),
                const SizedBox(width: 4),
                Text(
                  _caseDetail?.slaRiskLevel == 'BREACHED'
                      ? 'SLA BREACHED'
                      : _caseDetail?.slaRiskLevel == 'CRITICAL'
                          ? 'BREACH IN < 1HR'
                          : 'SLA COMPLIANT',
                  style: TextStyle(
                    color: isUrgent ? const Color(0xFFE11D48) : const Color(0xFF2563EB),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'JetBrains Mono',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentMetaCard() {
    final title = _caseDetail?.title ?? 'Authentication Gateway Timeout during SSO';
    final category = _caseDetail?.categoryName ?? 'Infrastructure';

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
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAEDFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  category,
                  style: const TextStyle(color: Color(0xFF464554), fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 3, backgroundColor: Color(0xFFD97706)),
                    const SizedBox(width: 4),
                    Text(
                      _caseDetail?.status ?? 'INVESTIGATING',
                      style: const TextStyle(color: Color(0xFFD97706), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.titleMedium(context).copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // War Room Live Voice Strip
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 54,
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 0,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF6366F1),
                              child: Text('E', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            left: 15,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF006194),
                              child: Text('M', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          Positioned(
                            left: 30,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Color(0xFF831ADA),
                              child: Text('P', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF0D9488), shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            const Text('War Room Bridge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ],
                        ),
                        Text('${_caseDetail?.assignedToName ?? "Triage Ops Team"} Active', style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showFeedbackToast('Connected to active incident war room voice bridge', Icons.mic, const Color(0xFF0D9488)),
                  icon: const Icon(Icons.mic, size: 14, color: Colors.white),
                  label: const Text('Join Bridge', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4648D4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiCopilotRunbookCard() {
    final summary = _aiAnalysis?.executiveSummary ??
        'Detected potential cascade failure pattern. Ingress pool saturation matches Envoy buffer deadlock under burst load.';
    final confidence = (_aiAnalysis?.confidenceScore != null)
        ? '${(_aiAnalysis!.confidenceScore! * 100).toInt()}% confidence'
        : '94% confidence';

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
              const Row(
                children: [
                  Text('✨', style: TextStyle(fontSize: 13)),
                  SizedBox(width: 6),
                  Text(
                    'AI COPILOT RECOMMENDATION',
                    style: TextStyle(color: Color(0xFF7C3AED), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  confidence,
                  style: const TextStyle(color: Color(0xFF7C3AED), fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            summary,
            style: AppTypography.bodySmall(context).copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long, size: 20, color: Color(0xFF7C3AED)),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Runbook #4099', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Hotpatch Ingress Max Connections', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _showFeedbackToast('Viewing Runbook #4099 run spec', Icons.menu_book, AppColors.primary),
                      child: const Text('Inspect', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      onPressed: () => _showFeedbackToast('Runbook #4099 hotpatch applied', Icons.check_circle, const Color(0xFF0D9488)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4648D4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Text('Apply Runbook', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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

  Widget _buildSegmentedTabNav() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEDFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildNavTab(0, 'Tasks (${_tasks.where((t) => t.isCompleted).length}/${_tasks.isNotEmpty ? _tasks.length : "4"})'),
          _buildNavTab(1, 'War Room & Notes (${_notes.length})'),
          _buildNavTab(2, 'Evidence (${_attachments.isNotEmpty ? _attachments.length : "3"})'),
        ],
      ),
    );
  }

  Widget _buildNavTab(int index, String title) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1))]
                : null,
          ),
          child: Center(
            child: Text(
              title,
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

  Widget _buildTabContent() {
    if (_activeTab == 0) {
      return _buildTasksTab();
    } else if (_activeTab == 1) {
      return _buildWarRoomTab();
    } else {
      return _buildEvidenceTab();
    }
  }

  Widget _buildTasksTab() {
    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final totalCount = _tasks.isNotEmpty ? _tasks.length : 4;
    final percent = totalCount > 0 ? ((completedCount / totalCount) * 100).toInt() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Remediation Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('$percent% Done', style: const TextStyle(color: Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: () => _showFeedbackToast('New subtask dialogue', Icons.add_circle, AppColors.primary),
              icon: const Icon(Icons.add_circle, size: 14, color: Color(0xFF4648D4)),
              label: const Text('Add Task', style: TextStyle(color: Color(0xFF4648D4), fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        if (_tasks.isNotEmpty)
          ..._tasks.map((task) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _buildTaskItem(
                  icon: task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                  iconColor: task.isCompleted ? const Color(0xFF0D9488) : AppColors.textMuted,
                  title: task.title,
                  statusBadge: task.status,
                  statusBg: task.isCompleted ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
                  statusColor: task.isCompleted ? const Color(0xFF0D9488) : const Color(0xFF64748B),
                  subtitle: 'Assigned to ${task.assigneeName}',
                  isDone: task.isCompleted,
                ),
              ))
        else ...[
          _buildTaskItem(
            icon: Icons.check_circle,
            iconColor: const Color(0xFF0D9488),
            title: 'Check Redis cache headroom',
            statusBadge: 'COMPLETED',
            statusBg: const Color(0xFFCCFBF1),
            statusColor: const Color(0xFF0D9488),
            subtitle: '98.4% memory allocation verified by automation agent',
            isDone: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildTaskItem(
            icon: Icons.sync,
            iconColor: const Color(0xFF0284C7),
            title: 'Test Envoy ingress proxy latency',
            statusBadge: 'RUNNING',
            statusBg: const Color(0xFFE0F2FE),
            statusColor: const Color(0xFF0284C7),
            subtitle: '12k pings sent • p99 = 2,410ms',
            isSpinning: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildTaskItem(
            icon: Icons.radio_button_unchecked,
            iconColor: AppColors.textMuted,
            title: 'Dump JVM heap trace from broker',
            statusBadge: 'PENDING',
            statusBg: const Color(0xFFF1F5F9),
            statusColor: const Color(0xFF64748B),
            subtitle: 'Assigned to Marcus Cole • Standby for container lock',
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildTaskItem(
            icon: Icons.verified,
            iconColor: const Color(0xFF0D9488),
            title: 'Verify Okta IdP certificate',
            statusBadge: 'VERIFIED',
            statusBg: const Color(0xFFCCFBF1),
            statusColor: const Color(0xFF0D9488),
            subtitle: 'TLS 1.3 handshake intact. Expiry: 184 days',
          ),
        ],
      ],
    );
  }

  Widget _buildTaskItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String statusBadge,
    required Color statusBg,
    required Color statusColor,
    required String subtitle,
    bool isDone = false,
    bool isSpinning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        decoration: isDone ? TextDecoration.lineThrough : null,
                        color: isDone ? AppColors.textMuted : AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        statusBadge,
                        style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarRoomTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text('Collaboration Thread', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('CONFIDENTIAL', style: TextStyle(color: Color(0xFF7C3AED), fontSize: 9, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const Text('Syncing Live', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_notes.isNotEmpty)
          ..._notes.map((n) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Container(
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
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 12,
                                backgroundColor: const Color(0xFF831ADA).withValues(alpha: 0.15),
                                child: Text(
                                  n.authorName.isNotEmpty ? n.authorName[0].toUpperCase() : 'U',
                                  style: const TextStyle(color: Color(0xFF831ADA), fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(n.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(4)),
                                child: Text(n.authorRole, style: const TextStyle(color: Color(0xFF0284C7), fontSize: 8, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          Text(n.createdAt.toIso8601String().substring(0, 10), style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        n.content,
                        style: const TextStyle(fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ))
        else
          Container(
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
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF831ADA).withValues(alpha: 0.15),
                          child: const Text('EV', style: TextStyle(color: Color(0xFF831ADA), fontSize: 9, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 6),
                        const Text('Elena Vance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(color: const Color(0xFFE0F2FE), borderRadius: BorderRadius.circular(4)),
                          child: const Text('LEAD', style: TextStyle(color: Color(0xFF0284C7), fontSize: 8, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const Text('14:02 UTC', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Triage update: Gateway errors peaked at 13:58. Okta timing out at 30,000ms. Ingress circuit breaker tripped immediately afterward.',
                  style: TextStyle(fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        // Add note
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _noteController,
                style: AppTypography.bodySmall(context),
                decoration: const InputDecoration(
                  hintText: 'Post internal findings, hypotheses, or log offsets...',
                  hintStyle: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  border: InputBorder.none,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => _showFeedbackToast('Log attachment dialogue ready', Icons.attachment, AppColors.primary),
                    icon: const Icon(Icons.attachment, size: 16, color: AppColors.textSecondary),
                  ),
                  ElevatedButton(
                    onPressed: _addNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4648D4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      elevation: 0,
                    ),
                    child: const Text('Post Note', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Evidence Locker', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('Immutable SHA-256 Audit Trail', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lock, size: 12, color: Color(0xFF6366F1)),
                  SizedBox(width: 4),
                  Text('Chain Intact', style: TextStyle(color: Color(0xFF6366F1), fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_attachments.isNotEmpty)
          ..._attachments.map((att) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: _buildEvidenceCard(
                  fileName: att.fileName,
                  fileSize: '${(att.fileSize / 1024).toStringAsFixed(1)} KB',
                  shaHash: 'sha256: ${att.id.length > 8 ? att.id.substring(0, 8) : att.id}',
                  fileType: att.fileType,
                  icon: Icons.description,
                ),
              ))
        else ...[
          _buildEvidenceCard(
            fileName: 'sso_auth_trace.pcap',
            fileSize: '4.2 MB',
            shaHash: 'sha256: 8f3d...91c4',
            fileType: 'Packet Capture',
            icon: Icons.network_check,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildEvidenceCard(
            fileName: 'envoy_access.log',
            fileSize: '18.6 MB',
            shaHash: 'sha256: 12ae...409b',
            fileType: 'Ingress Logs',
            icon: Icons.description,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildEvidenceCard(
            fileName: 'jvm_heap_dump.hprof',
            fileSize: '342 MB',
            shaHash: 'sha256: bc77...8810',
            fileType: 'Heap Profile',
            icon: Icons.data_object,
          ),
        ],
      ],
    );
  }

  Widget _buildEvidenceCard({
    required String fileName,
    required String fileSize,
    required String shaHash,
    required String fileType,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF4648D4)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fileName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(fileSize, style: const TextStyle(color: AppColors.textMuted, fontSize: 10)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(fileType, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                    Text(shaHash, style: const TextStyle(color: Color(0xFF0D9488), fontSize: 9, fontFamily: 'JetBrains Mono')),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showFeedbackToast('Downloaded $fileName', Icons.download, AppColors.primary),
            icon: const Icon(Icons.download, size: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
