import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import 'download_native_apps_modal.dart';
import '../../features/auth/presentation/auth_state_provider.dart';

class AppShell extends ConsumerStatefulWidget {
  final Widget child;
  final String currentPath;
  final String? title;
  final List<Widget>? actions;

  const AppShell({
    super.key,
    required this.child,
    required this.currentPath,
    this.title,
    this.actions,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (!isDesktop) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
        drawer: Drawer(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: _buildSidebarContent(context, isDark, user),
        ),
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          elevation: 0,
          scrolledUnderElevation: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, height: 1),
          ),
          title: Row(
            children: [
              _buildBrandMark(isDark, size: 28),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  widget.title ?? 'Nexus',
                  style: AppTypography.headlineSmall(isDark),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
              onPressed: () {
                ref.read(themeModeProvider.notifier).state =
                    isDark ? ThemeMode.light : ThemeMode.dark;
              },
            ),
            IconButton(
              icon: const Icon(Icons.install_mobile, size: 20),
              tooltip: 'Get Native Apps',
              onPressed: () => DownloadNativeAppsModal.show(context),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_outlined, size: 22),
              onPressed: () => context.go('/notifications'),
            ),
            if (widget.actions != null) ...widget.actions!,
            const SizedBox(width: 8),
          ],
        ),
        body: widget.child,
        bottomNavigationBar: _buildBottomNav(context, isDark, user),
      );
    }

    // === Desktop Enterprise Multi-Pane Layout (w-64 Sidebar + Top Header + Body) ===
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
      body: Row(
        children: [
          // 1. Fixed Left Sidebar (256px / w-64)
          Container(
            width: 256,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                right: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
            ),
            child: _buildSidebarContent(context, isDark, user),
          ),

          // 2. Main Content Area + Top Command Header
          Expanded(
            child: Column(
              children: [
                // Top Global Command Header (64px)
                _buildTopHeader(context, isDark, user),

                // Main Page Content Area
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, bool isDark, dynamic user) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.desktopGutter),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Row(
        children: [
          // Global Search with Ctrl+K badge
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      size: 20,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: AppTypography.bodySmall(isDark),
                        decoration: InputDecoration(
                          hintText: 'Search cases, operators, evidence, intelligence...',
                          hintStyle: AppTypography.bodySmall(isDark).copyWith(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                      child: Text('Ctrl + K', style: AppTypography.codeSmall(isDark)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Action buttons & Theme Switcher
          Row(
            children: [
              // Theme Switcher Pill
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.light,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: !isDark ? AppColors.lightSurface : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: !isDark
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)]
                              : null,
                        ),
                        child: Icon(
                          Icons.light_mode,
                          size: 16,
                          color: !isDark ? AppColors.accentPrimary : AppColors.darkTextMuted,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => ref.read(themeModeProvider.notifier).state = ThemeMode.dark,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: isDark
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]
                              : null,
                        ),
                        child: Icon(
                          Icons.dark_mode,
                          size: 16,
                          color: isDark ? AppColors.accentPrimaryDark : AppColors.lightTextMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Notifications with Red Breach Dot
              IconButton(
                icon: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      size: 22,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    Positioned(
                      top: 1,
                      right: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.statusBreachedTextLight,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                onPressed: () => context.go('/notifications'),
              ),

              // Get Native Apps Button
              IconButton(
                icon: Icon(
                  Icons.install_mobile,
                  size: 20,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                tooltip: 'Get Windows & Android Apps',
                onPressed: () => DownloadNativeAppsModal.show(context),
              ),

              Container(
                height: 24,
                width: 1,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              ),

              // User Profile Chip with Dropdown Menu
              PopupMenuButton<String>(
                offset: const Offset(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                onSelected: (val) {
                  if (val == 'downloads') {
                    DownloadNativeAppsModal.show(context);
                  } else if (val == 'logout') {
                    ref.read(authStateProvider.notifier).logout();
                    context.go('/auth/login');
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 18),
                        const SizedBox(width: 8),
                        Text('Signed in as ${user?.email ?? 'User'}', style: AppTypography.bodySmall(isDark)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'downloads',
                    child: Row(
                      children: [
                        const Icon(Icons.install_mobile, size: 18),
                        const SizedBox(width: 8),
                        Text('Get Native Apps (.exe / .apk)', style: AppTypography.bodySmall(isDark)),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: Colors.redAccent),
                        SizedBox(width: 8),
                        Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: isDark ? AppColors.accentTintDark : AppColors.accentTintLight,
                      child: Text(
                        (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user?.name ?? 'Elena Vance',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          user?.primaryRole ?? 'Lead Operator',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.expand_more,
                      size: 18,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
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

  Widget _buildSidebarContent(BuildContext context, bool isDark, dynamic user) {
    return Column(
      children: [
        // Brand Header (h-16 / 64px)
        Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildBrandMark(isDark),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Nexus', style: AppTypography.headlineSmall(isDark)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Text('v3.0', style: AppTypography.codeSmall(isDark)),
              ),
            ],
          ),
        ),

        // AI Copilot Active Badge Pill
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.aiBgDark : AppColors.aiBgLight,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.aiBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 14,
                      color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'AI COPILOT ACTIVE',
                      style: TextStyle(
                        color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Workspace Label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'WORKSPACE',
              style: TextStyle(
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),

        // Navigation Links
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
            children: _buildRoleSpecificNavItems(context, isDark, user),
          ),
        ),

        // Clean User Session Footer (Production RBAC)
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: isDark ? AppColors.accentTintDark : AppColors.accentTintLight,
                child: Text(
                  (user?.name ?? 'U').substring(0, 1).toUpperCase(),
                  style: TextStyle(
                    color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      user?.name ?? 'Nexus User',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.accentTintDark : AppColors.accentTintLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user?.primaryRole ?? 'REQUESTER',
                        style: TextStyle(
                          color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                tooltip: 'Sign Out',
                onPressed: () {
                  ref.read(authStateProvider.notifier).logout();
                  context.go('/auth/login');
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required bool isDark,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          final scaffold = Scaffold.maybeOf(context);
          if (scaffold != null && scaffold.isDrawerOpen) {
            Navigator.of(context).pop();
          }
          context.go(route);
        },
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.accentTintDark : AppColors.accentTintLight)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                size: 19,
                color: isActive
                    ? (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary)
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive
                        ? (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRoleSpecificNavItems(BuildContext context, bool isDark, dynamic user) {
    final path = widget.currentPath;
    final role = user?.primaryRole ?? 'REQUESTER';

    switch (role) {
      case 'ADMIN':
        return [
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.manage_accounts_outlined,
            activeIcon: Icons.manage_accounts,
            label: 'User Management',
            route: '/admin/users',
            isActive: path.startsWith('/admin/users'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.rule_folder_outlined,
            activeIcon: Icons.rule_folder,
            label: 'SLA Policy Builder',
            route: '/admin/policies',
            isActive: path.startsWith('/admin/policies'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.history_edu_outlined,
            activeIcon: Icons.history_edu,
            label: 'Audit Trail Ledger',
            route: '/admin/audit-logs',
            isActive: path.startsWith('/admin/audit-logs'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights,
            label: 'Executive Analytics',
            route: '/dashboard/manager',
            isActive: path.startsWith('/dashboard/manager') || path.startsWith('/analytics'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Notifications',
            route: '/notifications',
            isActive: path.startsWith('/notifications'),
          ),
        ];

      case 'MANAGER':
        return [
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights,
            label: 'Executive Analytics',
            route: '/dashboard/manager',
            isActive: path.startsWith('/dashboard/manager') || path.startsWith('/analytics'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.troubleshoot_outlined,
            activeIcon: Icons.troubleshoot,
            label: 'Problem Management',
            route: '/problems',
            isActive: path.startsWith('/problems'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.shield_outlined,
            activeIcon: Icons.shield,
            label: 'SLA Risk Radar',
            route: '/sla/risk-console',
            isActive: path.startsWith('/sla/risk-console'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.inbox_outlined,
            activeIcon: Icons.inbox,
            label: 'Triage Workstation',
            route: '/dashboard/operator/triage',
            isActive: path.startsWith('/dashboard/operator') || path == '/cases',
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Notifications',
            route: '/notifications',
            isActive: path.startsWith('/notifications'),
          ),
        ];

      case 'TEAM_LEAD':
        return [
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            label: 'Team Command',
            route: '/dashboard/team-lead',
            isActive: path.startsWith('/dashboard/team-lead'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.inbox_outlined,
            activeIcon: Icons.inbox,
            label: 'Triage Workstation',
            route: '/dashboard/operator/triage',
            isActive: path.startsWith('/dashboard/operator') || path == '/cases',
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.shield_outlined,
            activeIcon: Icons.shield,
            label: 'SLA Risk Radar',
            route: '/sla/risk-console',
            isActive: path.startsWith('/sla/risk-console'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.troubleshoot_outlined,
            activeIcon: Icons.troubleshoot,
            label: 'Problem Management',
            route: '/problems',
            isActive: path.startsWith('/problems'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Notifications',
            route: '/notifications',
            isActive: path.startsWith('/notifications'),
          ),
        ];

      case 'OPERATOR':
        return [
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.inbox_outlined,
            activeIcon: Icons.inbox,
            label: 'Triage Workstation',
            route: '/dashboard/operator/triage',
            isActive: path.startsWith('/dashboard/operator') || path == '/cases',
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.terminal_outlined,
            activeIcon: Icons.terminal,
            label: 'Investigation Studio',
            route: '/cases/66666666-6666-6666-6666-666666666661/investigation',
            isActive: path.startsWith('/cases/') && path != '/cases/new',
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.shield_outlined,
            activeIcon: Icons.shield,
            label: 'SLA Risk Radar',
            route: '/sla/risk-console',
            isActive: path.startsWith('/sla/risk-console'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.troubleshoot_outlined,
            activeIcon: Icons.troubleshoot,
            label: 'Problem Management',
            route: '/problems',
            isActive: path.startsWith('/problems'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Notifications',
            route: '/notifications',
            isActive: path.startsWith('/notifications'),
          ),
        ];

      case 'REQUESTER':
      default:
        return [
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.space_dashboard_outlined,
            activeIcon: Icons.space_dashboard,
            label: 'Requester Portal',
            route: '/dashboard/requester',
            isActive: path.startsWith('/dashboard/requester'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.add_circle_outline,
            activeIcon: Icons.add_circle,
            label: 'Report New Issue',
            route: '/cases/new',
            isActive: path.startsWith('/cases/new'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.timeline_outlined,
            activeIcon: Icons.timeline,
            label: 'Track My Issue',
            route: '/cases/66666666-6666-6666-6666-666666666663/track',
            isActive: path.contains('/track'),
          ),
          _buildNavItem(
            context: context,
            isDark: isDark,
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: 'Notifications',
            route: '/notifications',
            isActive: path.startsWith('/notifications'),
          ),
        ];
    }
  }

  Widget _buildBrandMark(bool isDark, {double size = 32}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.accentPrimary, AppColors.aiLilac],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Center(
        child: Text(
          'N',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.55,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, bool isDark, dynamic user) {
    final role = user?.primaryRole ?? user?.role ?? 'OPERATOR';
    final path = widget.currentPath;

    List<_BottomNavItem> items;
    switch (role) {
      case 'ADMIN':
        items = [
          _BottomNavItem(icon: Icons.group_outlined, activeIcon: Icons.group, label: 'Users', route: '/admin/users', isActive: path.startsWith('/admin/users')),
          _BottomNavItem(icon: Icons.policy_outlined, activeIcon: Icons.policy, label: 'SLA', route: '/admin/policies', isActive: path.startsWith('/admin/policies')),
          _BottomNavItem(icon: Icons.history_outlined, activeIcon: Icons.history, label: 'Audit', route: '/admin/audit-logs', isActive: path.startsWith('/admin/audit-logs')),
          _BottomNavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'KPIs', route: '/dashboard/manager', isActive: path.startsWith('/dashboard/manager')),
          _BottomNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Alerts', route: '/notifications', isActive: path.startsWith('/notifications')),
        ];
        break;
      case 'MANAGER':
      case 'TEAM_LEAD':
        items = [
          _BottomNavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'KPIs', route: '/dashboard/manager', isActive: path.startsWith('/dashboard/manager')),
          _BottomNavItem(icon: Icons.group_work_outlined, activeIcon: Icons.group_work, label: 'Squad', route: '/dashboard/team-lead', isActive: path.startsWith('/dashboard/team-lead')),
          _BottomNavItem(icon: Icons.radar_outlined, activeIcon: Icons.radar, label: 'Radar', route: '/sla/risk-console', isActive: path.startsWith('/sla/risk-console')),
          _BottomNavItem(icon: Icons.report_problem_outlined, activeIcon: Icons.report_problem, label: 'Problems', route: '/problems', isActive: path.startsWith('/problems')),
          _BottomNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Alerts', route: '/notifications', isActive: path.startsWith('/notifications')),
        ];
        break;
      case 'REQUESTER':
        items = [
          _BottomNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Portal', route: '/dashboard/requester', isActive: path == '/dashboard/requester'),
          _BottomNavItem(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, label: 'Report', route: '/cases/new', isActive: path.startsWith('/cases/new')),
          _BottomNavItem(icon: Icons.timeline_outlined, activeIcon: Icons.timeline, label: 'Track', route: '/cases/66666666-6666-6666-6666-666666666663/track', isActive: path.contains('/track')),
          _BottomNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Alerts', route: '/notifications', isActive: path.startsWith('/notifications')),
          const _BottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile', route: '/dashboard/requester', isActive: false),
        ];
        break;
      case 'OPERATOR':
      default:
        items = [
          _BottomNavItem(icon: Icons.inbox_outlined, activeIcon: Icons.inbox, label: 'Triage', route: '/dashboard/operator/triage', isActive: path.startsWith('/dashboard/operator/triage')),
          _BottomNavItem(icon: Icons.dataset_outlined, activeIcon: Icons.dataset, label: 'Studio', route: '/cases/66666666-6666-6666-6666-666666666661/investigation', isActive: path.contains('/investigation') || path.contains('/collaboration') || path.contains('/copilot')),
          _BottomNavItem(icon: Icons.radar_outlined, activeIcon: Icons.radar, label: 'Radar', route: '/sla/risk-console', isActive: path.startsWith('/sla/risk-console')),
          _BottomNavItem(icon: Icons.report_problem_outlined, activeIcon: Icons.report_problem, label: 'Problems', route: '/problems', isActive: path.startsWith('/problems')),
          _BottomNavItem(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, label: 'Alerts', route: '/notifications', isActive: path.startsWith('/notifications')),
        ];
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkSurface : AppColors.lightSurface).withValues(alpha: 0.95),
        border: Border(
          top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              const activeColor = AppColors.accentPrimary;
              final inactiveColor = isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    if (item.route.isNotEmpty) context.go(item.route);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.isActive ? item.activeIcon : item.icon,
                        color: item.isActive ? activeColor : inactiveColor,
                        size: 22,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: item.isActive ? FontWeight.w600 : FontWeight.w500,
                          color: item.isActive ? activeColor : inactiveColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final bool isActive;

  const _BottomNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.isActive,
  });
}

