import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/nexus_button.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../data/notification_api.dart';

/// Notification model representing cross-channel alerts
class AppNotificationItem {
  final String id;
  final String title;
  final String message;
  final String category; // 'sla', 'ai', 'mention', 'system'
  final String timestamp;
  final String priority; // 'critical', 'high', 'medium', 'low'
  final bool isRead;
  final String? caseId;
  final String? caseTitle;
  final String? senderName;
  final String? senderAvatar;
  final String? aiPlaybookName;

  AppNotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    required this.priority,
    required this.isRead,
    this.caseId,
    this.caseTitle,
    this.senderName,
    this.senderAvatar,
    this.aiPlaybookName,
  });

  AppNotificationItem copyWith({
    bool? isRead,
  }) {
    return AppNotificationItem(
      id: id,
      title: title,
      message: message,
      category: category,
      timestamp: timestamp,
      priority: priority,
      isRead: isRead ?? this.isRead,
      caseId: caseId,
      caseTitle: caseTitle,
      senderName: senderName,
      senderAvatar: senderAvatar,
      aiPlaybookName: aiPlaybookName,
    );
  }
}

/// SCR-18: Global Notification Center Screen
/// Real-time centralized dispatch & alert management matrix with SLA breach triggers,
/// AI playbook one-tap deployment, and inline mention replies.
class GlobalNotificationCenterScreen extends ConsumerStatefulWidget {
  const GlobalNotificationCenterScreen({super.key});

  @override
  ConsumerState<GlobalNotificationCenterScreen> createState() => _GlobalNotificationCenterScreenState();
}

class _GlobalNotificationCenterScreenState extends ConsumerState<GlobalNotificationCenterScreen> {
  String _selectedCategory = 'ALL';
  bool _showUnreadOnly = false;
  bool _isLoading = false;
  String? _errorMessage;

  final Map<String, TextEditingController> _replyControllers = {};

  List<AppNotificationItem> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await NotificationApi().getMyNotifications();
    if (mounted) {
      if (res.success && res.data != null) {
        final items = res.data!.map((n) {
          String category = 'system';
          String priority = 'low';
          final typeUpper = n.type.toUpperCase();

          if (typeUpper.contains('SLA') || typeUpper.contains('BREACH') || typeUpper.contains('ESCALAT')) {
            category = 'sla';
            priority = 'critical';
          } else if (typeUpper.contains('AI') || typeUpper.contains('SUGGESTION') || typeUpper.contains('SUMMARY')) {
            category = 'ai';
            priority = 'high';
          } else if (typeUpper.contains('MENTION') || typeUpper.contains('MESSAGE')) {
            category = 'mention';
            priority = 'medium';
          }

          final diff = DateTime.now().difference(n.createdAt);
          String timeStr = '${diff.inMinutes}m ago';
          if (diff.inMinutes < 1) {
            timeStr = 'Just now';
          } else if (diff.inHours < 24 && diff.inMinutes >= 60) {
            timeStr = '${diff.inHours}h ago';
          } else if (diff.inDays >= 1) {
            timeStr = '${diff.inDays}d ago';
          }

          return AppNotificationItem(
            id: n.id,
            title: n.title,
            message: n.message,
            category: category,
            timestamp: timeStr,
            priority: priority,
            isRead: n.isRead,
            caseId: n.caseId,
            caseTitle: n.caseId != null ? 'Case #${n.caseId}' : null,
          );
        }).toList();

        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res.error ?? 'Failed to load notifications';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _replyControllers.values) {
      controller.dispose();
    }
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

  Future<void> _markAllAsRead() async {
    setState(() {
      _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    });
    await NotificationApi().markAllAsRead();
    _showFeedbackToast('All notifications marked as read', Icons.done_all_rounded, AppColors.success);
  }

  Future<void> _toggleReadStatus(String id) async {
    final item = _notifications.firstWhere((n) => n.id == id, orElse: () => _notifications.first);
    final nextStatus = !item.isRead;
    setState(() {
      _notifications = _notifications.map((n) {
        if (n.id == id) {
          return n.copyWith(isRead: nextStatus);
        }
        return n;
      }).toList();
    });
    if (nextStatus) {
      await NotificationApi().markAsRead(id);
    }
  }

  List<AppNotificationItem> get _filteredNotifications {
    return _notifications.where((item) {
      if (_showUnreadOnly && item.isRead) return false;
      if (_selectedCategory == 'ALL') return true;
      if (_selectedCategory == 'SLA' && item.category == 'sla') return true;
      if (_selectedCategory == 'AI' && item.category == 'ai') return true;
      if (_selectedCategory == 'MENTIONS' && item.category == 'mention') return true;
      if (_selectedCategory == 'SYSTEM' && item.category == 'system') return true;
      return false;
    }).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/notifications',
      title: 'Notification Center',
      actions: [
        if (_unreadCount > 0)
          TextButton.icon(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded, size: 16),
            label: Text('Mark Read ($_unreadCount)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
      ],
      child: ResponsiveLayout(
        mobileBody: _buildMobileBody(context),
        desktopBody: _buildDesktopBody(context),
      ),
    );
  }

  Widget _buildMobileBody(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(context),
        Expanded(
          child: _buildFeedContent(context, const EdgeInsets.all(AppSpacing.md)),
        ),
      ],
    );
  }

  Widget _buildDesktopBody(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sidebar metrics & quick categories
        SizedBox(
          width: 320,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DISPATCH CHANNELS',
                  style: AppTypography.labelSmall(context).copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _buildChannelTile(context, 'ALL', 'All Notifications', _notifications.length, Icons.inbox_rounded, AppColors.primaryBlue),
                _buildChannelTile(context, 'SLA', 'SLA Critical Breaches', _notifications.where((n) => n.category == 'sla').length, Icons.warning_amber_rounded, AppColors.error),
                _buildChannelTile(context, 'AI', 'AI Copilot Playbooks', _notifications.where((n) => n.category == 'ai').length, Icons.auto_awesome_rounded, AppColors.aiAccent),
                _buildChannelTile(context, 'MENTIONS', 'Direct Mentions', _notifications.where((n) => n.category == 'mention').length, Icons.alternate_email_rounded, const Color(0xFF8B5CF6)),
                _buildChannelTile(context, 'SYSTEM', 'System & Security', _notifications.where((n) => n.category == 'system').length, Icons.shield_outlined, AppColors.textSecondary),
                const Divider(height: AppSpacing.xl),
                // Priority SLA Quick Alert
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.error, size: 20),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            'Active Escalation Watch',
                            style: AppTypography.labelMedium(context).copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '1 case is within 15 minutes of SLA breach with Tier-1 severity.',
                        style: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const VerticalDivider(width: 1, thickness: 1, color: AppColors.borderGrey),
        // Main feed
        Expanded(
          child: Column(
            children: [
              _buildFilterBar(context),
              Expanded(
                child: _buildFeedContent(context, const EdgeInsets.all(AppSpacing.lg)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedContent(BuildContext context, EdgeInsets padding) {
    if (_isLoading) {
      return const NexusLoadingView(message: 'Syncing real-time notifications & dispatch queue...');
    }
    if (_errorMessage != null) {
      return NexusErrorView(message: _errorMessage!, onRetry: _loadNotifications);
    }
    if (_filteredNotifications.isEmpty) {
      return _buildEmptyState(context);
    }
    return ListView.separated(
      padding: padding,
      itemCount: _filteredNotifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final item = _filteredNotifications[index];
        return _buildNotificationCard(context, item);
      },
    );
  }

  Widget _buildChannelTile(
    BuildContext context,
    String categoryKey,
    String label,
    int count,
    IconData icon,
    Color activeColor,
  ) {
    final isSelected = _selectedCategory == categoryKey;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _selectedCategory = categoryKey),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 20, color: isSelected ? activeColor : AppColors.textSecondary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium(context).copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? activeColor : AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? activeColor : AppColors.borderGrey.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: AppTypography.labelSmall(context).copyWith(
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final categories = ['ALL', 'SLA', 'AI', 'MENTIONS', 'SYSTEM'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      selected: isSelected,
                      label: Text(cat),
                      labelStyle: AppTypography.labelSmall(context).copyWith(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      ),
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: const Color(0xFFF1F5F9),
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      side: BorderSide.none,
                      onSelected: (val) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Unread only',
                style: AppTypography.labelSmall(context).copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(width: AppSpacing.xs),
              Switch(
                value: _showUnreadOnly,
                activeThumbColor: AppColors.primaryBlue,
                onChanged: (val) => setState(() => _showUnreadOnly = val),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotificationItem item) {
    Color badgeColor;
    IconData categoryIcon;
    switch (item.category) {
      case 'sla':
        badgeColor = AppColors.error;
        categoryIcon = Icons.warning_amber_rounded;
        break;
      case 'ai':
        badgeColor = AppColors.aiAccent;
        categoryIcon = Icons.auto_awesome_rounded;
        break;
      case 'mention':
        badgeColor = const Color(0xFF8B5CF6);
        categoryIcon = Icons.alternate_email_rounded;
        break;
      default:
        badgeColor = AppColors.primaryBlue;
        categoryIcon = Icons.info_outline_rounded;
    }

    final isUnread = !item.isRead;

    return Container(
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : const Color(0xFFFBFBFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnread ? badgeColor.withValues(alpha: 0.3) : AppColors.borderGrey.withValues(alpha: 0.8),
          width: isUnread ? 1.5 : 1.0,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: badgeColor.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(categoryIcon, color: badgeColor, size: 20),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppTypography.bodyMedium(context).copyWith(
                                fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Text(
                            item.timestamp,
                            style: AppTypography.labelSmall(context).copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      if (item.caseId != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.caseId!,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                              ),
                            ),
                            if (item.caseTitle != null) ...[
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: Text(
                                  item.caseTitle!,
                                  style: AppTypography.labelSmall(context).copyWith(
                                    color: AppColors.textSecondary,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                IconButton(
                  tooltip: isUnread ? 'Mark read' : 'Mark unread',
                  icon: Icon(
                    isUnread ? Icons.mark_email_read_outlined : Icons.mark_email_unread_outlined,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () => _toggleReadStatus(item.id),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              item.message,
              style: AppTypography.bodyMedium(context).copyWith(
                color: const Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ),
          // Contextual Action Block
          if (item.category == 'sla') _buildSlaActionBox(context, item),
          if (item.category == 'ai' && item.aiPlaybookName != null) _buildAiPlaybookActionBox(context, item),
          if (item.category == 'mention') _buildMentionQuickReplyBox(context, item),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  Widget _buildSlaActionBox(BuildContext context, AppNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.alarm_on_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              'Automated Tier-2 Manager paging in 10 mins if unacknowledged.',
              style: AppTypography.labelSmall(context).copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          NexusButton(
            label: 'Escalate Now',
            icon: Icons.trending_up_rounded,
            variant: ButtonVariant.danger,
            size: ButtonSize.small,
            onPressed: () {
              _showFeedbackToast('Priority Failover Escalation Dispatched', Icons.done, AppColors.error);
              _toggleReadStatus(item.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAiPlaybookActionBox(BuildContext context, AppNotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.aiAccent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.aiAccent.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.aiAccent, size: 18),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended Playbook:',
                  style: AppTypography.labelSmall(context).copyWith(color: AppColors.textSecondary, fontSize: 10),
                ),
                Text(
                  item.aiPlaybookName!,
                  style: AppTypography.labelMedium(context).copyWith(
                    color: AppColors.aiAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          NexusButton(
            label: '1-Tap Apply',
            icon: Icons.bolt_rounded,
            variant: ButtonVariant.primary,
            size: ButtonSize.small,
            onPressed: () {
              _showFeedbackToast('Applied: ${item.aiPlaybookName}', Icons.auto_awesome, AppColors.aiAccent);
              _toggleReadStatus(item.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMentionQuickReplyBox(BuildContext context, AppNotificationItem item) {
    if (!_replyControllers.containsKey(item.id)) {
      _replyControllers[item.id] = TextEditingController();
    }
    final controller = _replyControllers[item.id]!;

    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.md, right: AppSpacing.md, top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Reply to ${item.senderName ?? "sender"} inline...',
                hintStyle: AppTypography.bodySmall(context).copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              ),
              style: AppTypography.bodySmall(context),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send_rounded, color: AppColors.primaryBlue, size: 18),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _showFeedbackToast('Sent reply to ${item.senderName}', Icons.send_rounded, AppColors.primaryBlue);
                controller.clear();
                _toggleReadStatus(item.id);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_none_rounded, size: 56, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'All caught up!',
            style: AppTypography.headingSmall(context).copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'No notifications match your current active filter.',
            style: AppTypography.bodyMedium(context).copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
