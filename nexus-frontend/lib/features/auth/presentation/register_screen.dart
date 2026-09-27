import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/nexus_button.dart';
import 'auth_state_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'REQUESTER';
  String _selectedOrg = 'Acme Corporation';
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0.0;
    double score = 0.0;
    if (password.length >= 8) score += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) score += 0.25;
    if (password.contains(RegExp(r'[0-9]'))) score += 0.25;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) score += 0.2;
    return score.clamp(0.0, 1.0);
  }

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'All fields are required.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final repo = ref.read(authRepositoryProvider);
    final result = await repo.register(
      name: name,
      email: email,
      password: password,
      role: _selectedRole,
    );

    setState(() => _isLoading = false);

    if (result.success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful! Please sign in.')),
      );
      context.go('/auth/login');
    } else {
      setState(() => _errorMessage = result.error ?? 'Registration failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.mobileGutter),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
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
                    // Brand Header
                    Row(
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
                            child: Text('N', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('Nexus', style: AppTypography.headlineSmall(isDark)),
                        const Spacer(),
                        InkWell(
                          onTap: () => context.go('/auth/login'),
                          child: Text(
                            'Back to Login',
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

                    Text('Create Enterprise Account', style: AppTypography.headlineSmall(isDark)),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Join your organization workspace to report and manage cases.',
                      style: AppTypography.bodySmall(isDark),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Error Message
                    if (_errorMessage != null) ...[
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
                            Icon(Icons.error_outline, size: 18, color: isDark ? AppColors.statusBreachedTextDark : AppColors.statusBreachedTextLight),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                _errorMessage!,
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

                    // Full Name
                    Text('Full Name', style: AppTypography.titleSmall(isDark)),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Elena Vance',
                        prefixIcon: Icon(Icons.person_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Work Email
                    Text('Work Email', style: AppTypography.titleSmall(isDark)),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: 'name@organization.com',
                        prefixIcon: Icon(Icons.mail_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Organization & Role (Stacked on mobile, 2 columns on tablet/desktop)
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 400;
                        final orgField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Organization', style: AppTypography.titleSmall(isDark)),
                            const SizedBox(height: AppSpacing.xs),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedOrg,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'Acme Corporation', child: Text('Acme Corp', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'Nexus Enterprise', child: Text('Nexus Enterprise', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'Global Logistics', child: Text('Global Logistics', overflow: TextOverflow.ellipsis)),
                              ],
                              onChanged: (val) => setState(() => _selectedOrg = val ?? _selectedOrg),
                            ),
                          ],
                        );

                        final roleField = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Initial Role', style: AppTypography.titleSmall(isDark)),
                            const SizedBox(height: AppSpacing.xs),
                            DropdownButtonFormField<String>(
                              initialValue: _selectedRole,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'REQUESTER', child: Text('Requester', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'CASE_OPERATOR', child: Text('Case Operator', overflow: TextOverflow.ellipsis)),
                                DropdownMenuItem(value: 'TEAM_LEAD', child: Text('Team Lead', overflow: TextOverflow.ellipsis)),
                              ],
                              onChanged: (val) => setState(() => _selectedRole = val ?? _selectedRole),
                            ),
                          ],
                        );

                        if (isNarrow) {
                          return Column(
                            children: [
                              orgField,
                              const SizedBox(height: AppSpacing.md),
                              roleField,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: orgField),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(child: roleField),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password
                    Text('Password', style: AppTypography.titleSmall(isDark)),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Min 8 chars, 1 uppercase & symbol',
                        prefixIcon: const Icon(Icons.lock_outline, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    // Password Strength Indicator Bar
                    _buildPasswordStrengthBar(isDark),
                    const SizedBox(height: AppSpacing.md),

                    // Confirm Password
                    Text('Confirm Password', style: AppTypography.titleSmall(isDark)),
                    const SizedBox(height: AppSpacing.xs),
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      decoration: const InputDecoration(
                        hintText: 'Re-enter your password',
                        prefixIcon: Icon(Icons.lock_outline, size: 20),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Submit Button
                    NexusButton(
                      text: 'Create Account',
                      width: double.infinity,
                      isLoading: _isLoading,
                      onPressed: _handleRegister,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text('Already have an account? ', style: AppTypography.bodySmall(isDark)),
                          InkWell(
                            onTap: () => context.go('/auth/login'),
                            child: Text(
                              'Sign In',
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
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordStrengthBar(bool isDark) {
    final strength = _calculatePasswordStrength(_passwordController.text);
    Color strengthColor = AppColors.statusBreachedTextLight;
    String strengthLabel = 'Weak';

    if (strength >= 0.75) {
      strengthColor = isDark ? AppColors.statusClosedTextDark : AppColors.statusClosedTextLight;
      strengthLabel = 'Strong';
    } else if (strength >= 0.4) {
      strengthColor = isDark ? AppColors.statusInvestigatingTextDark : AppColors.statusInvestigatingTextLight;
      strengthLabel = 'Medium';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: strength,
            minHeight: 4,
            backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
            valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
          ),
        ),
        if (_passwordController.text.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Strength: $strengthLabel',
                style: TextStyle(color: strengthColor, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              Text('8+ characters recommended', style: AppTypography.labelSmall(isDark)),
            ],
          ),
        ],
      ],
    );
  }
}
