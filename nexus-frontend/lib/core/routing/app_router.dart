import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/admin_sla_policy_builder_screen.dart';
import '../../features/admin/presentation/admin_user_management_screen.dart';
import '../../features/analytics/presentation/executive_analytics_kpi_screen.dart';
import '../../features/audit/presentation/audit_trail_timeline_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/case/presentation/case_create_wizard_screen.dart';
import '../../features/case/presentation/case_tracker_screen.dart';
import '../../features/collaboration/presentation/case_collaboration_evidence_hub_screen.dart';
import '../../features/copilot/presentation/ai_copilot_smart_drafter_screen.dart';
import '../../features/dashboard/operator/operator_triage_feed_screen.dart';
import '../../features/dashboard/requester/requester_dashboard_screen.dart';
import '../../features/dashboard/team_lead/team_lead_command_screen.dart';
import '../../features/downloads/presentation/downloads_screen.dart';
import '../../features/investigation/presentation/operator_investigation_studio_screen.dart';
import '../../features/notification/presentation/global_notification_center_screen.dart';
import '../../features/problem/presentation/problem_management_hub_screen.dart';
import '../../features/resolution/presentation/resolution_proposal_closure_screen.dart';
import '../../features/sla/presentation/sla_risk_radar_console_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth/login',
    routes: [
      // Public Downloads Route
      GoRoute(
        path: '/downloads',
        builder: (context, state) => const DownloadsScreen(),
      ),
      // Auth routes (SCR-01 & SCR-02)
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Dashboard routes (SCR-03 & SCR-06 & SCR-11 & SCR-14)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) {
          return const RequesterDashboardScreen();
        },
      ),
      GoRoute(
        path: '/dashboard/requester',
        builder: (context, state) => const RequesterDashboardScreen(),
      ),
      GoRoute(
        path: '/dashboard/operator/triage',
        builder: (context, state) => const OperatorTriageFeedScreen(),
      ),
      GoRoute(
        path: '/cases',
        builder: (context, state) => const OperatorTriageFeedScreen(),
      ),
      GoRoute(
        path: '/dashboard/team-lead',
        builder: (context, state) => const TeamLeadCommandScreen(),
      ),
      GoRoute(
        path: '/dashboard/manager',
        builder: (context, state) => const ExecutiveAnalyticsKpiScreen(),
      ),
      GoRoute(
        path: '/analytics',
        builder: (context, state) => const ExecutiveAnalyticsKpiScreen(),
      ),

      // Case & Tracking routes (SCR-04 & SCR-05)
      GoRoute(
        path: '/cases/new',
        builder: (context, state) => const CaseCreateWizardScreen(),
      ),
      GoRoute(
        path: '/cases/create',
        builder: (context, state) => const CaseCreateWizardScreen(),
      ),
      GoRoute(
        path: '/cases/:id/track',
        builder: (context, state) {
          final caseId = state.pathParameters['id'] ?? 'NEX-2026-0042';
          return CaseTrackerScreen(caseId: caseId);
        },
      ),

      // Investigation & Collaboration routes (SCR-07 & SCR-08)
      GoRoute(
        path: '/cases/:id',
        builder: (context, state) {
          final caseId = state.pathParameters['id'] ?? 'NEX-2026-0104';
          return OperatorInvestigationStudioScreen(caseId: caseId);
        },
      ),
      GoRoute(
        path: '/cases/:id/investigation',
        builder: (context, state) {
          final caseId = state.pathParameters['id'] ?? 'NEX-2026-0104';
          return OperatorInvestigationStudioScreen(caseId: caseId);
        },
      ),
      GoRoute(
        path: '/cases/:id/collaboration',
        builder: (context, state) {
          final caseId = state.pathParameters['id'] ?? 'NEX-2026-0104';
          return CaseCollaborationEvidenceHubScreen(caseId: caseId);
        },
      ),

      // Copilot & Resolution routes (SCR-09 & SCR-10)
      GoRoute(
        path: '/cases/:id/copilot',
        builder: (context, state) {
          final caseId = state.pathParameters['id'] ?? 'NEX-2026-0104';
          return AiCopilotSmartDrafterScreen(caseId: caseId);
        },
      ),
      GoRoute(
        path: '/cases/:id/resolve',
        builder: (context, state) {
          final caseId = state.pathParameters['id'] ?? 'NEX-2026-0104';
          return ResolutionProposalClosureScreen(caseId: caseId);
        },
      ),

      // SLA Risk Radar & Escalation Console (SCR-12)
      GoRoute(
        path: '/sla/risk-console',
        builder: (context, state) => const SlaRiskRadarConsoleScreen(),
      ),

      // Problem Management & Root Cause Hub (SCR-13)
      GoRoute(
        path: '/problems',
        builder: (context, state) => const ProblemManagementHubScreen(),
      ),

      // Batch 8: Admin User Management (SCR-15) & SLA Policy Builder (SCR-16)
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/policies',
        builder: (context, state) => const AdminSlaPolicyBuilderScreen(),
      ),
      GoRoute(
        path: '/admin/sla-policies',
        redirect: (context, state) => '/admin/policies',
      ),

      // Batch 9: Audit Trail Timeline (SCR-17) & Global Notification Center (SCR-18)
      GoRoute(
        path: '/admin/audit-logs',
        builder: (context, state) => const AuditTrailTimelineScreen(),
      ),
      GoRoute(
        path: '/admin/audit',
        redirect: (context, state) => '/admin/audit-logs',
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const GlobalNotificationCenterScreen(),
      ),
    ],
  );
});
