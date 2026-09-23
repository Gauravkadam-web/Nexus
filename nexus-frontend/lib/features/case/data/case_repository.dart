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

  Future<({bool success, CaseModel? caseItem, String? error})> getCaseDetail(String id) async {
    final res = await _api.getCaseDetail(id);
    if (res.success && res.data != null) {
      return (success: true, caseItem: res.data, error: null);
    }
    return (success: false, caseItem: null, error: res.error);
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
    return (success: false, data: null, error: res.error);
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
}
