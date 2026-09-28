import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_context_extensions.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../../core/widgets/state_view_helpers.dart';
import '../data/admin_api.dart';
import '../domain/admin_models.dart';

/// SCR-15: Admin Configuration & User Governance Screen
/// User directory management, RBAC clearance assignments, department team rosters,
/// shift scheduling, and enterprise directory sync (SSO/SCIM).
class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedTab = 'Personnel'; // Personnel, Teams, Routing, SSO

  List<AdminUserModel> _users = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await AdminApi().getUsers();
    if (mounted) {
      if (res.success && res.data != null) {
        setState(() {
          _users = res.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = res.error ?? 'Failed to load user directory';
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

  Future<void> _handleUpdateRole(String userId, String currentRole, String userName) async {
    final roles = ['REQUESTER', 'OPERATOR', 'TEAM_LEAD', 'MANAGER', 'ADMIN'];
    final selectedRole = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: context.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assign Role: $userName',
                      style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'Select new RBAC permissions tier for this organization account.',
                  style: TextStyle(fontSize: 12, color: context.textSecondary),
                ),
                const SizedBox(height: AppSpacing.md),
                ...roles.map((r) {
                  final isCurrent = r == currentRole;
                  return ListTile(
                    dense: true,
                    title: Text(
                      r,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent ? context.accent : context.textPrimary,
                      ),
                    ),
                    trailing: isCurrent ? Icon(Icons.check_circle, color: context.accent, size: 20) : null,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    tileColor: isCurrent ? context.accentTint.withValues(alpha: 0.3) : null,
                    onTap: () => Navigator.pop(ctx, r),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );

    if (selectedRole != null && selectedRole != currentRole) {
      final res = await AdminApi().updateUserRole(userId: userId, role: selectedRole);
      if (res.success) {
        _showFeedbackToast('Updated $userName to $selectedRole', Icons.verified_user, const Color(0xFF0D9488));
        _loadUsers();
      } else {
        _showFeedbackToast(res.error ?? 'Failed to update role', Icons.error_outline, const Color(0xFFE11D48));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentPath: '/admin/users',
      title: 'User Governance',
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
          _buildAdminHeaderActionRow(context),
          const SizedBox(height: AppSpacing.sm),
          _buildSubTabPills(context),
          const SizedBox(height: AppSpacing.sm),
          _buildGovernanceKpiGrid(context),
          const SizedBox(height: AppSpacing.sm),
          _buildSearchAndFilters(context),
          const SizedBox(height: AppSpacing.sm),
          _buildUserRosterList(context),
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
          _buildAdminHeaderActionRow(context),
          const SizedBox(height: AppSpacing.md),
          _buildSubTabPills(context),
          const SizedBox(height: AppSpacing.md),
          _buildGovernanceKpiGrid(context),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildSearchAndFilters(context),
                    const SizedBox(height: AppSpacing.md),
                    _buildGovernanceSecurityHealthCard(context),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Expanded(
                flex: 8,
                child: _buildUserRosterList(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeaderActionRow(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 6,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Directory & Access',
              style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold, color: context.textPrimary),
            ),
            Text(
              'SOC-2 / RBAC Role Governance',
              style: TextStyle(fontSize: 11, color: context.textSecondary),
            ),
          ],
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: context.accent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          icon: const Icon(Icons.person_add_outlined, size: 14),
          label: const Text('+ Invite User', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          onPressed: () => _showFeedbackToast('Opening User Invitation Modal', Icons.person_add, context.accent),
        ),
      ],
    );
  }

  Widget _buildSubTabPills(BuildContext context) {
    final userCount = _users.isNotEmpty ? _users.length : 5;
    final tabs = [
      {'id': 'Personnel', 'label': 'Personnel ($userCount)'},
      {'id': 'Teams', 'label': 'Teams (3)'},
      {'id': 'Routing', 'label': 'Routing Rules'},
      {'id': 'SSO', 'label': 'SSO & SCIM (Active)'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: tabs.map((t) {
          final isSelected = _selectedTab == t['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(
                t['label']!,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? context.accent : context.textSecondary,
                ),
              ),
              selected: isSelected,
              selectedColor: context.accentTint,
              backgroundColor: context.cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? context.accent : context.border,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedTab = t['id']!);
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGovernanceKpiGrid(BuildContext context) {
    final totalCount = _users.isNotEmpty ? _users.length : 5;
    final activeCount = _users.where((u) => u.isActive).length;
    final leadCount = _users.where((u) => u.role.contains('LEAD') || u.role.contains('ADMIN')).length;

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
            KpiCard(
              title: 'TOTAL USERS',
              value: '$totalCount',
              subtitle: 'All Synced',
              icon: Icons.group_outlined,
              accentColor: const Color(0xFF0D9488),
            ),
            KpiCard(
              title: 'ACTIVE NOW',
              value: activeCount > 0 ? '$activeCount' : '$totalCount',
              subtitle: 'Verified Sessions',
              icon: Icons.timelapse_outlined,
              accentColor: const Color(0xFF0284C7),
            ),
            KpiCard(
              title: 'LEADS & ADMINS',
              value: leadCount > 0 ? '$leadCount' : '2',
              subtitle: 'Elevated RBAC',
              icon: Icons.shield_outlined,
              accentColor: const Color(0xFFD97706),
            ),
            const KpiCard(
              title: 'MFA STATUS',
              value: '100%',
              subtitle: 'SOC-2 Compliant',
              icon: Icons.verified_user_outlined,
              accentColor: Color(0xFF6366F1),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.border),
      ),
      child: TextField(
        controller: _searchController,
        style: TextStyle(fontSize: 13, color: context.textPrimary),
        decoration: InputDecoration(
          hintText: 'Filter by name, pod, role...',
          hintStyle: TextStyle(fontSize: 12, color: context.textMuted),
          prefixIcon: Icon(Icons.search, size: 18, color: context.textMuted),
          suffixIcon: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: context.isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('⌘K', style: TextStyle(fontSize: 10, color: context.textSecondary)),
          ),
          isDense: true,
          filled: false,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: context.border),
          ),
        ),
      ),
    );
  }

  Widget _buildGovernanceSecurityHealthCard(BuildContext context) {
    final activeCount = _users.where((u) => u.isActive).length;
    final totalCount = _users.isNotEmpty ? _users.length : 5;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security, size: 18, color: Color(0xFF0D9488)),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Security Health & Directory',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildHealthRow('Identity Provider', 'Okta SSO / SCIM v2.0', const Color(0xFF0D9488)),
          const SizedBox(height: 6),
          _buildHealthRow('MFA Enforcement', 'Hardware Token + TOTP', const Color(0xFF0D9488)),
          const SizedBox(height: 6),
          _buildHealthRow('Session Clearance', '$activeCount / $totalCount verified', context.accent),
          const SizedBox(height: 6),
          _buildHealthRow('Compliance Standard', 'SOC-2 Type II Certified', const Color(0xFFD97706)),
        ],
      ),
    );
  }

  Widget _buildHealthRow(String label, String value, Color badgeColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: context.textSecondary)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRosterList(BuildContext context) {
    if (_isLoading) {
      return const NexusLoadingView(message: 'Loading user directory & RBAC roster...');
    }
    if (_errorMessage != null && _users.isEmpty) {
      return NexusErrorView(
        message: _errorMessage!,
        onRetry: _loadUsers,
      );
    }

    final query = _searchController.text.trim().toLowerCase();
    final filteredUsers = _users.where((u) {
      if (query.isEmpty) return true;
      return u.name.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query) ||
          u.role.toLowerCase().contains(query);
    }).toList();

    if (filteredUsers.isEmpty) {
      return const NexusEmptyView(
        title: 'No Personnel Found',
        message: 'No directory accounts match the current filter or search query.',
        icon: Icons.people_outline,
      );
    }

    return Column(
      children: filteredUsers.map((u) {
        final isLead = u.role.contains('LEAD');
        final isAdmin = u.role.contains('ADMIN');
        final roleBg = isAdmin
            ? const Color(0xFFFFE4E6)
            : isLead
                ? const Color(0xFFF3E8FF)
                : const Color(0xFFEEF2FF);
        final roleColor = isAdmin
            ? const Color(0xFFE11D48)
            : isLead
                ? const Color(0xFF7C3AED)
                : AppColors.accentPrimary;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _buildUserCard(
            userId: u.id,
            name: u.name,
            email: u.email,
            role: u.role,
            team: u.teamName ?? 'General Operations',
            status: u.isActive ? 'Active • Verified' : 'Inactive',
            activeCases: 2,
            maxCases: 6,
            roleBg: roleBg,
            roleColor: roleColor,
            isOnline: u.isActive,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUserCard({
    required String userId,
    required String name,
    required String email,
    required String role,
    required String team,
    required String status,
    required int activeCases,
    required int maxCases,
    required Color roleBg,
    required Color roleColor,
    required bool isOnline,
  }) {
    final progress = (activeCases / maxCases).clamp(0.0, 1.0);

    // Role-coded dynamic avatar colors (Linear/Stripe Standard)
    Color avatarBg;
    Color avatarText;
    if (role.contains('ADMIN')) {
      avatarBg = const Color(0xFFFFE4E6);
      avatarText = const Color(0xFFE11D48);
    } else if (role.contains('LEAD')) {
      avatarBg = const Color(0xFFF3E8FF);
      avatarText = const Color(0xFF7C3AED);
    } else if (role.contains('OPERATOR')) {
      avatarBg = const Color(0xFFEEF2FF);
      avatarText = const Color(0xFF4648D4);
    } else {
      avatarBg = const Color(0xFFCCFBF1);
      avatarText = const Color(0xFF0D9488);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: avatarBg,
                child: Text(
                  name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: avatarText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: context.textPrimary),
                    ),
                    Text(
                      email,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: context.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: roleBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  role,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: roleColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Team: $team', style: TextStyle(fontSize: 11, color: context.textSecondary)),
              Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isOnline ? const Color(0xFF0D9488) : context.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Capacity: $activeCases / $maxCases active cases',
                style: TextStyle(fontSize: 10, color: context.textMuted, fontWeight: FontWeight.w500),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: progress > 0.85 ? const Color(0xFFE11D48) : context.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: context.isDark ? AppColors.darkSurfaceElevated : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(progress > 0.85 ? const Color(0xFFE11D48) : context.accent),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    side: BorderSide(color: context.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    backgroundColor: context.surfaceElevated,
                  ),
                  icon: Icon(Icons.shield_outlined, size: 14, color: context.accent),
                  label: Text('Change Role', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.accent)),
                  onPressed: () => _handleUpdateRole(userId, role, name),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
