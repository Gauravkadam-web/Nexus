import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/nexus_button.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../../admin/data/admin_api.dart';
import '../../admin/domain/admin_models.dart';
import 'case_state_provider.dart';

class CaseCreateWizardScreen extends ConsumerStatefulWidget {
  const CaseCreateWizardScreen({super.key});

  @override
  ConsumerState<CaseCreateWizardScreen> createState() => _CaseCreateWizardScreenState();
}

class _CaseCreateWizardScreenState extends ConsumerState<CaseCreateWizardScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategoryId = '33333333-3333-3333-3333-333333333331';
  String _selectedSeverity = 'MEDIUM';
  final List<String> _attachedFiles = ['system_error_trace.log'];
  bool _isSubmitting = false;
  String? _errorMessage;

  List<CategoryModel> _availableCategories = [];

  final severities = ['LOW', 'MEDIUM', 'HIGH', 'CRITICAL'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final res = await AdminApi().getCategories();
    if (res.success && res.data != null && res.data!.isNotEmpty && mounted) {
      setState(() {
        _availableCategories = res.data!;
        _selectedCategoryId = _availableCategories.first.id;
      });
    } else {
      setState(() {
        _availableCategories = const [
          CategoryModel(id: '33333333-3333-3333-3333-333333333331', name: 'Network & VPN Infrastructure'),
          CategoryModel(id: '33333333-3333-3333-3333-333333333332', name: 'Software Access & Licensing'),
          CategoryModel(id: '33333333-3333-3333-3333-333333333333', name: 'Hardware & IT Workstations'),
          CategoryModel(id: '33333333-3333-3333-3333-333333333334', name: 'Cloud Infrastructure & SRE'),
        ];
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      setState(() => _errorMessage = 'Case title and description are required.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final success = await ref.read(caseStateProvider.notifier).createCase(
          title: title,
          description: description,
          categoryId: _selectedCategoryId,
          severity: _selectedSeverity,
        );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF065F46),
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Support case submitted successfully!'),
            ],
          ),
        ),
      );
      context.go('/dashboard/requester');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppShell(
      currentPath: '/cases/new',
      title: 'Report a Support Case',
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveLayout.isMobile(context)
              ? AppSpacing.mobileGutter
              : AppSpacing.desktopGutter,
          vertical: AppSpacing.lg,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: ResponsiveLayout(
              mobile: (context, constraints) => _buildMobileLayout(context, isDark),
              desktop: (context, constraints) => _buildDesktopLayout(context, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: _buildMainForm(context, isDark),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          flex: 35,
          child: _buildHelperPanel(context, isDark),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return Column(
      children: [
        _buildMainForm(context, isDark),
        const SizedBox(height: AppSpacing.xl),
        _buildHelperPanel(context, isDark),
      ],
    );
  }

  Widget _buildMainForm(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPaddingDesktop),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Case Details', style: AppTypography.headlineSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Provide clear details to help operators triage and resolve the issue quickly.',
            style: AppTypography.bodySmall(isDark),
          ),
          const SizedBox(height: AppSpacing.lg),

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Case Summary / Title *', style: AppTypography.titleSmall(isDark)),
              Text(
                '${_titleController.text.length}/100',
                style: AppTypography.labelSmall(isDark),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _titleController,
            maxLength: 100,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'e.g. Authentication Gateway Timeout during SSO federation',
              prefixIcon: Icon(Icons.title, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          Text('Category *', style: AppTypography.titleSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: _availableCategories.map((cat) {
              final isSelected = _selectedCategoryId == cat.id;
              return ChoiceChip(
                label: Text(cat.name),
                selected: isSelected,
                selectedColor: isDark ? AppColors.accentTintDark : AppColors.accentTintLight,
                backgroundColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                labelStyle: TextStyle(
                  color: isSelected
                      ? (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary)
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 13,
                ),
                side: BorderSide(
                  color: isSelected
                      ? (isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary)
                      : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedCategoryId = cat.id;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Severity Level *', style: AppTypography.titleSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: severities.map((sev) {
              final isSelected = _selectedSeverity == sev;
              Color badgeColor;
              switch (sev) {
                case 'LOW':
                  badgeColor = AppColors.statusClosedTextLight;
                  break;
                case 'MEDIUM':
                  badgeColor = AppColors.statusInvestigatingTextLight;
                  break;
                case 'HIGH':
                  badgeColor = AppColors.statusWaitingTextLight;
                  break;
                case 'CRITICAL':
                default:
                  badgeColor = AppColors.statusBreachedTextLight;
                  break;
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: () => setState(() => _selectedSeverity = sev),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? badgeColor.withValues(alpha: 0.15)
                            : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: isSelected ? badgeColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          sev,
                          style: TextStyle(
                            color: isSelected ? badgeColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Detailed Description *', style: AppTypography.titleSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _descriptionController,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Describe what happened, error codes observed, affected environment, and steps to reproduce...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text('Attachments & Evidence', style: AppTypography.titleSmall(isDark)),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 32,
                  color: isDark ? AppColors.accentPrimaryDark : AppColors.accentPrimary,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text('Logs, diagnostic traces, and error screenshots attached', style: AppTypography.bodySmall(isDark)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.xs,
                  children: _attachedFiles.map((f) {
                    return Chip(
                      label: Text(f, style: const TextStyle(fontSize: 12)),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () => setState(() => _attachedFiles.remove(f)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          Wrap(
            alignment: WrapAlignment.end,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              NexusButton(
                text: 'Cancel / Draft',
                variant: NexusButtonVariant.ghost,
                onPressed: () => context.go('/dashboard/requester'),
              ),
              NexusButton(
                text: 'Submit Support Case',
                icon: Icons.send,
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelperPanel(BuildContext context, bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingDesktop),
          decoration: BoxDecoration(
            color: isDark ? AppColors.aiBgDark : AppColors.aiBgLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.aiBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac),
                  const SizedBox(width: 6),
                  Text(
                    'PROACTIVE AI GUIDELINES',
                    style: TextStyle(
                      color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.04,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTipItem(
                isDark,
                Icons.speed,
                'Faster Diagnosis',
                'Attaching log snippets and exact error codes helps operators triage 2x faster.',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTipItem(
                isDark,
                Icons.security_outlined,
                'Sensitive Data Shield',
                'Do not include unmasked production passwords or secret API keys in description.',
              ),
              const SizedBox(height: AppSpacing.md),
              _buildTipItem(
                isDark,
                Icons.auto_fix_high,
                'Smart Auto-Assignment',
                'Based on category and severity, Nexus will automatically route your case to the optimal available specialist.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTipItem(bool isDark, IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 16, color: isDark ? AppColors.aiLilacDark : AppColors.aiLilac),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleSmall(isDark)),
              const SizedBox(height: 2),
              Text(description, style: AppTypography.bodySmall(isDark)),
            ],
          ),
        ),
      ],
    );
  }
}
