class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String refresh = 'auth/refresh';
  static const String logout = 'auth/logout';
  static const String me = 'auth/me';

  // Cases
  static const String cases = 'cases';
  static const String myCases = 'cases/my';
  static const String assignedCases = 'cases/assigned';
  static const String teamCases = 'cases/team';
  static String caseDetail(String id) => 'cases/$id';
  static String caseStatus(String id) => 'cases/$id/status';
  static String caseAssign(String id) => 'cases/$id/assign';
  static String caseAttachments(String id) => 'cases/$id/attachments';
  static String caseTimeline(String id) => 'cases/$id/timeline';
  static String caseRelations(String id) => 'cases/$id/relations';
  static String masterIncidentChildren(String id) => 'cases/$id/master-incident/children';
  static const String caseSearch = 'cases/search';

  // Collaboration
  static String caseMessages(String id) => 'cases/$id/messages';
  static String caseNotes(String id) => 'cases/$id/notes';
  static String caseTasks(String id) => 'cases/$id/tasks';
  static String taskStatus(String id) => 'tasks/$id';
  static String caseInvestigations(String id) => 'cases/$id/investigations';
  static const String teamWorkload = 'collaboration/workload/team';

  // AI
  static String aiAnalyze(String id) => 'cases/$id/ai/analyze';
  static String aiAnalysis(String id) => 'cases/$id/ai/analysis';
  static String aiSummary(String id) => 'cases/$id/ai/summary';
  static String aiSummaryRegenerate(String id) => 'cases/$id/ai/summary/regenerate';
  static String aiSuggestionDecision(String id) => 'ai/suggestions/$id';
  static String aiDuplicates(String id) => 'cases/$id/ai/duplicates';
  static String aiAssignmentRec(String id) => 'cases/$id/ai/assignment-recommendation';
  static String aiDraftComm(String id) => 'cases/$id/ai/draft-communication';
  static String aiCopilot(String id) => 'cases/$id/ai/copilot';

  // SLA & Escalation
  static String caseSla(String id) => 'cases/$id/sla';
  static const String slaAtRisk = 'sla/at-risk';
  static const String slaBreached = 'sla/breached';
  static String caseEscalate(String id) => 'cases/$id/escalate';
  static const String escalations = 'escalations';

  // Resolution
  static String caseResolution(String id) => 'cases/$id/resolution';
  static String caseResolutionConfirm(String id) => 'cases/$id/resolution/confirm';
  static String caseResolutionReject(String id) => 'cases/$id/resolution/reject';

  // Problem Management
  static const String problems = 'problems';
  static String problemDetail(String id) => 'problems/$id';
  static String problemIncidents(String id) => 'problems/$id/incidents';
  static const String problemRecurringPatterns = 'problems/recurring-patterns';

  // Notifications
  static const String notifications = 'notifications';
  static String notificationRead(String id) => 'notifications/$id/read';
  static const String notificationsReadAll = 'notifications/read-all';

  // Analytics
  static const String analyticsOverview = 'analytics/overview';
  static const String analyticsTrends = 'analytics/trends';
  static const String analyticsCategories = 'analytics/categories';
  static const String analyticsTeams = 'analytics/teams';
  static const String analyticsOperationalInsights = 'analytics/operational-insights';

  // Organization & Admin
  static const String adminUsers = 'admin/users';
  static String adminUserRole(String id) => 'admin/users/$id/role';
  static const String teams = 'teams';
  static String teamDetail(String id) => 'teams/$id';
  static const String categories = 'categories';
  static String categoryDetail(String id) => 'categories/$id';
  static const String adminSlaPolicies = 'admin/sla-policies';
  static String adminSlaPolicyDetail(String id) => 'admin/sla-policies/$id';
  static const String adminEscalationRules = 'admin/escalation-rules';
  static String adminEscalationRuleDetail(String id) => 'admin/escalation-rules/$id';
  static const String auditLogs = 'audit-logs';
  static String auditLogCaseTimeline(String id) => 'audit-logs/case/$id/timeline';
}
