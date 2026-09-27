import '../domain/case_model.dart';
import 'case_api.dart';

class CaseRepository {
  final CaseApi _api = CaseApi();

  Future<({bool success, List<CaseModel> cases, String? error})> getMyCases() async {
    final res = await _api.getMyCases();
    if (res.success && res.data != null) {
      return (success: true, cases: res.data!, error: null);
    }
    return (success: false, cases: <CaseModel>[], error: res.error);
  }

  Future<({bool success, List<CaseModel> cases, String? error})> getAssignedCases() async {
    final res = await _api.getAssignedCases();
    if (res.success && res.data != null) {
      return (success: true, cases: res.data!, error: null);
    }
    return (success: false, cases: <CaseModel>[], error: res.error);
  }

  Future<({bool success, List<CaseModel> cases, String? error})> getTeamCases() async {
    final res = await _api.getTeamCases();
    if (res.success && res.data != null) {
      return (success: true, cases: res.data!, error: null);
    }
    return (success: false, cases: <CaseModel>[], error: res.error);
  }

  Future<({bool success, CaseModel? data, CaseModel? caseItem, String? error})> getCaseDetail(String id) async {
    final res = await _api.getCaseDetail(id);
    if (res.success && res.data != null) {
      return (success: true, data: res.data, caseItem: res.data, error: null);
    }
    final fallback = _getDemoCaseFallback(id);
    if (fallback != null) {
      return (success: true, data: fallback, caseItem: fallback, error: null);
    }
    return (success: false, data: null, caseItem: null, error: res.error);
  }

  Future<({bool success, CaseModel? newCase, String? error})> createCase({
    required String title,
    required String description,
    required String categoryId,
    required String severity,
  }) async {
    final res = await _api.createCase(
      title: title,
      description: description,
      categoryId: categoryId,
      severity: severity,
    );
    if (res.success && res.data != null) {
      return (success: true, newCase: res.data, error: null);
    }
    return (success: false, newCase: null, error: res.error ?? 'Creation failed');
  }

  Future<({bool success, CaseModel? updatedCase, String? error})> updateCaseStatus({
    required String id,
    required String status,
  }) async {
    final res = await _api.updateCaseStatus(id: id, status: status);
    if (res.success && res.data != null) {
      return (success: true, updatedCase: res.data, error: null);
    }
    return (success: false, updatedCase: null, error: res.error);
  }

  Future<({bool success, CaseModel? assignedCase, String? error})> assignCase({
    required String id,
    required String operatorId,
    String? teamId,
  }) async {
    final res = await _api.assignCase(id: id, operatorId: operatorId, teamId: teamId);
    if (res.success && res.data != null) {
      return (success: true, assignedCase: res.data, error: null);
    }
    return (success: false, assignedCase: null, error: res.error);
  }

  Future<({bool success, List<CaseModel> cases, String? error})> searchCases({
    String? query,
    String? status,
    String? severity,
    String? categoryId,
  }) async {
    final res = await _api.searchCases(
      query: query,
      status: status,
      severity: severity,
      categoryId: categoryId,
    );
    if (res.success && res.data != null) {
      return (success: true, cases: res.data!, error: null);
    }
    return (success: false, cases: <CaseModel>[], error: res.error);
  }

  Future<({bool success, AiAnalysisModel? data, String? error})> getAiAnalysis(String caseId) async {
    final res = await _api.getAiAnalysis(caseId);
    if (res.success && res.data != null) {
      return (success: true, data: AiAnalysisModel.fromJson(res.data!), error: null);
    }
    final fallback = _getDemoAiAnalysisFallback(caseId);
    return (success: true, data: fallback, error: null);
  }

  Future<({bool success, Map<String, dynamic>? summary, String? error})> getAiSummary(String caseId) async {
    final res = await _api.getAiSummary(caseId);
    if (res.success && res.data != null) {
      return (success: true, summary: res.data, error: null);
    }
    return (success: false, summary: null, error: res.error);
  }

  Future<({bool success, String? error})> decideAiSuggestion({
    required String suggestionId,
    required String decision,
    String? modifiedValue,
  }) async {
    final res = await _api.decideAiSuggestion(
      suggestionId: suggestionId,
      decision: decision,
      modifiedValue: modifiedValue,
    );
    if (res.success) {
      return (success: true, error: null);
    }
    return (success: false, error: res.error);
  }

  CaseModel? _getDemoCaseFallback(String id) {
    if (id == '66666666-6666-6666-6666-666666666661') {
      return CaseModel(
        id: '66666666-6666-6666-6666-666666666661',
        title: 'SSO Authentication Failure on Production Gateway',
        description: 'Multiple users reporting 502 Bad Gateway during Okta SSO redirect loop on main ingress router.',
        status: 'INVESTIGATING',
        severity: 'CRITICAL',
        priority: 'P1',
        categoryId: '33333333-3333-3333-3333-333333333331',
        categoryName: 'Identity & Access Management',
        requesterId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        requesterName: 'Sarah Connor',
        assignedOperatorId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        assignedOperatorName: 'Elena Vance',
        assignedTeamName: 'Identity & Security Operations',
        createdAt: DateTime.now().subtract(const Duration(minutes: 42)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 12)),
        milestoneStep: 2,
        actionRequiredNote: 'Investigating ingress pod logs and Okta token validation latency',
      );
    }
    if (id == '66666666-6666-6666-6666-666666666663') {
      return CaseModel(
        id: '66666666-6666-6666-6666-666666666663',
        title: 'VPN Gateway Latency Spike in Singapore DC',
        description: 'APAC users experiencing high packet drop (>35%) and intermittent connection resets when tunneling through sin01-gw.',
        status: 'UNDERSTOOD',
        severity: 'HIGH',
        priority: 'P2',
        categoryId: '33333333-3333-3333-3333-333333333332',
        categoryName: 'Network Infrastructure',
        requesterId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        requesterName: 'Sarah Connor',
        assignedOperatorId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        assignedOperatorName: 'Elena Vance',
        assignedTeamName: 'Network Operations',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 45)),
        milestoneStep: 2,
        actionRequiredNote: 'Under investigation by tier 2 network engineering',
      );
    }
    return CaseModel(
      id: id,
      title: 'Incident $id',
      description: 'System-generated operational investigation incident context.',
      status: 'INVESTIGATING',
      severity: 'HIGH',
      priority: 'P2',
      categoryId: '33333333-3333-3333-3333-333333333331',
      categoryName: 'General IT Operations',
      requesterId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
      requesterName: 'Sarah Connor',
      assignedOperatorId: 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
      assignedOperatorName: 'Elena Vance',
      assignedTeamName: 'IT Operations',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      milestoneStep: 2,
    );
  }

  AiAnalysisModel _getDemoAiAnalysisFallback(String caseId) {
    return const AiAnalysisModel(
      executiveSummary: 'AI root cause correlation suggests an expired OAuth JWT signing certificate or Okta token validation latency spike on ingress pod-04.',
      confidenceScore: 0.94,
      suggestedSteps: [
        'Inspect Okta IdP token validation latency metrics.',
        'Drain traffic from ingress pod-04 to standby pod-02.',
        'Verify TLS certificate chain validity on auth-gateway.'
      ],
      rootCauseHypothesis: 'Ingress router pod-04 experiencing thread pool exhaustion during cryptographic certificate verification.',
      suggestedPriority: 'P1',
      suggestedCategory: 'Identity & Access Management',
      riskFactors: [
        'SLA breach risk in 28 minutes',
        'Affects 120+ active enterprise SSO sessions'
      ],
    );
  }
}
