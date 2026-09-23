import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nexus_button.dart';
import '../../../core/widgets/responsive_layout.dart';
import 'auth_state_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both Email and Password'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final success = await ref.read(authStateProvider.notifier).login(email, password);
    if (!mounted) return;

    if (success) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        if (user.isAdmin) {
          context.go('/admin/users');
        } else if (user.isManager) {
          context.go('/dashboard/manager');
        } else if (user.isTeamLead) {
          context.go('/dashboard/team-lead');
        } else if (user.isOperator) {
          context.go('/dashboard/operator/triage');
        } else {
          context.go('/dashboard/requester');
        }
      } else {
        context.go('/dashboard/requester');
      }
    } else {
      final error = ref.read(authStateProvider).errorMessage ?? 'Invalid email or password. Please verify credentials.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _handleDemoRoleLogin(String role) async {
    final success = await ref.read(authStateProvider.notifier).loginAsDemoRole(role);
    if (!mounted) return;
    if (success) {
      switch (role.toUpperCase()) {
        case 'ADMIN':
        case 'ADMINISTRATOR':
          context.go('/admin/users');
          break;
        case 'MANAGER':
          context.go('/dashboard/manager');
          break;
        case 'TEAM_LEAD':
          context.go('/dashboard/team-lead');
          break;
        case 'CASE_OPERATOR':
        case 'OPERATOR':
          context.go('/dashboard/operator/triage');
          break;
        case 'REQUESTER':
        default:
          context.go('/dashboard/requester');
          break;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      body: ResponsiveLayout(
        mobile: (context, constraints) => _buildMobileLayout(context, isDark, authState),
        desktop: (context, constraints) => _buildDesktopLayout(context, isDark, authState),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark, AuthState authState) {
    return Row(
      children: [
        // Left Column: Brand Showcase (45%)
        Expanded(
          flex: 5,
          child: Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Brand Mark
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.accentPrimary, AppColors.aiLilac],
                          ),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Center(
                          child: Text(
                            'N',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Text('Nexus', style: AppTypography.headlineMedium(isDark)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                        child: Text('v3.0 Enterprise', style: AppTypography.codeSmall(isDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Center Tagline & Features
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.aiBgDark : AppColors.aiBgLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          border: Border.all(color: AppColors.aiBorder),
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            Icon(Icons.auto_awesome, size: 14, color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac),
                            Text(
                              'AI-Powered Case Management Platform',
                              style: TextStyle(
                                color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Intelligent Case Management with Complete Human Oversight',
                      style: AppTypography.displayLarge(isDark),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Automate root-cause analysis, streamline cross-functional investigation, and prevent SLA breaches with verified AI recommendations.',
                      style: AppTypography.bodyMedium(isDark),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildFeatureBullet(isDark, Icons.verified_user_outlined, 'Strict Human-in-the-Loop AI decisions'),
                    const SizedBox(height: AppSpacing.md),
                    _buildFeatureBullet(isDark, Icons.timer_outlined, 'Predictive SLA Breach Radar & Auto-Escalation'),
                    const SizedBox(height: AppSpacing.md),
                    _buildFeatureBullet(isDark, Icons.history_edu_outlined, 'Immutable Cryptographic Audit Trail'),
                  ],
                ),
                // Footer
                Text(
                  '© 2026 Nexus Enterprise Systems. All rights reserved.',
                  style: AppTypography.labelSmall(isDark),
                ),
              ],
            ),
          ),
        ),
      ),
        // Divider
        Container(
          width: 1,
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        // Right Column: Centered Login Form (55%)
        Expanded(
          flex: 6,
          child: Container(
            color: isDark ? AppColors.darkCanvas : AppColors.lightCanvas,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: _buildLoginFormCard(context, isDark, authState),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark, AuthState authState) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.mobileGutter),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              children: [
                // Mobile Brand Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accentPrimary, AppColors.aiLilac],
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Center(
                        child: Text(
                          'N',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Nexus', style: AppTypography.headlineSmall(isDark)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildLoginFormCard(context, isDark, authState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginFormCard(BuildContext context, bool isDark, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingDesktop),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sign In', style: AppTypography.headlineSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Enter your enterprise credentials to access workstation.',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Error Message Display
          if (authState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isDark ? AppColors.statusBreachedBgDark : AppColors.statusBreachedBgLight,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isDark ? AppColors.statusBreachedTextDark : AppColors.statusBreachedTextLight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 18,
                    color: isDark ? AppColors.statusBreachedTextDark : AppColors.statusBreachedTextLight,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      authState.errorMessage!,
                      style: TextStyle(
                        color: isDark ? AppColors.statusBreachedTextDark : AppColors.statusBreachedTextLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Email Field
          Text('Email Address', style: AppTypography.titleSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            key: const ValueKey('login_email_input'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.email, AutofillHints.username],
            decoration: InputDecoration(
              hintText: 'name@company.com',
              prefixIcon: Icon(Icons.mail_outline, size: 20, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Password Field
          Text('Password', style: AppTypography.titleSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            key: const ValueKey('login_password_input'),
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => _handleLogin(),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: Icon(Icons.lock_outline, size: 20, color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                ),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Remember Me & Forgot Password
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      onChanged: (val) => setState(() => _rememberMe = val ?? true),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text('Remember me', style: AppTypography.bodySmall(isDark)),
                ],
              ),
              InkWell(
                onTap: () {},
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Sign In Button
          NexusButton(
            text: 'Sign In',
            width: double.infinity,
            isLoading: authState.isLoading,
            onPressed: _handleLogin,
          ),
          const SizedBox(height: AppSpacing.md),

          // Register Link
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text("Don't have an account? ", style: AppTypography.bodySmall(isDark)),
                InkWell(
                  onTap: () => context.go('/auth/register'),
                  child: Text(
                    'Register now',
                    style: TextStyle(
                      color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 1-Click Quick Demo Role Access
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  children: [
                    Icon(Icons.bolt, size: 16, color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary),
                    Text('1-Click Quick Test Access:', style: AppTypography.codeSmall(isDark)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _buildQuickRoleChip(context, isDark, 'Operator', 'OPERATOR'),
                    _buildQuickRoleChip(context, isDark, 'Requester', 'REQUESTER'),
                    _buildQuickRoleChip(context, isDark, 'Team Lead', 'TEAM_LEAD'),
                    _buildQuickRoleChip(context, isDark, 'Manager', 'MANAGER'),
                    _buildQuickRoleChip(context, isDark, 'Admin', 'ADMIN'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRoleChip(BuildContext context, bool isDark, String label, String role) {
    return InkWell(
      onTap: () => _handleDemoRoleLogin(role),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBullet(bool isDark, IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.accentTintDark : AppColors.accentTintLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 16, color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium(isDark),
          ),
        ),
      ],
    );
  }
}
