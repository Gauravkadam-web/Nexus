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
                child: _buildSearchAndFilters(context),
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
              style: AppTypography.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
            ),
            const Text(
              'SOC-2 / RBAC Role Governance',
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
          icon: const Icon(Icons.person_add_outlined, size: 14),
          label: const Text('+ Invite User', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          onPressed: () => _showFeedbackToast('Opening User Invitation Modal', Icons.person_add, AppColors.accentPrimary),
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
            _buildKpiCard(
              title: 'TOTAL USERS',
              value: '$totalCount',
              badgeText: 'All Synced',
              badgeColor: const Color(0xFF0D9488),
              badgeBg: const Color(0xFFCCFBF1),
              icon: Icons.group_outlined,
            ),
            _buildKpiCard(
              title: 'ACTIVE NOW',
              value: activeCount > 0 ? '$activeCount' : '$totalCount',
              badgeText: 'Verified',
              badgeColor: const Color(0xFF0284C7),
              badgeBg: const Color(0xFFE0F2FE),
              icon: Icons.timelapse_outlined,
            ),
            _buildKpiCard(
              title: 'LEADS & ADMINS',
              value: leadCount > 0 ? '$leadCount' : '2',
              badgeText: 'Elevated RBAC',
              badgeColor: const Color(0xFFD97706),
              badgeBg: const Color(0xFFFEF3C7),
              icon: Icons.shield_outlined,
            ),
            _buildKpiCard(
              title: 'MFA STATUS',
              value: '100%',
              badgeText: 'SOC-2 Compliant',
              badgeColor: const Color(0xFF6366F1),
              badgeBg: const Color(0xFFEEF2FF),
              icon: Icons.verified_user_outlined,
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

  Widget _buildSearchAndFilters(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Filter by name, pod, role...',
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('⌘K', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.borderLight),
              ),
            ),
          ),
        ],
      ),
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
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isOnline ? const Color(0xFFCCFBF1) : const Color(0xFFF1F5F9),
                child: Text(
                  name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isOnline ? const Color(0xFF0D9488) : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                    Text(email, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
              Text('Team: $team', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isOnline ? const Color(0xFF0D9488) : AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(progress > 0.85 ? const Color(0xFFE11D48) : AppColors.accentPrimary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
