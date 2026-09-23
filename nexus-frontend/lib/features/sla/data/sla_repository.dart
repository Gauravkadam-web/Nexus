import '../domain/sla_model.dart';
import 'sla_api.dart';

class SlaRepository {
  final SlaApi _api = SlaApi();

  Future<({bool success, CaseSlaModel? sla, String? error})> getCaseSla(String caseId) async {
    final res = await _api.getCaseSla(caseId);
    if (res.success && res.data != null) {
      return (success: true, sla: res.data, error: null);
    }
    return (success: false, sla: null, error: res.error);
  }

  Future<({bool success, List<SlaRiskCaseModel> cases, String? error})> getAtRiskCases() async {
    final res = await _api.getAtRiskCases();
    if (res.success && res.data != null) {
      return (success: true, cases: res.data!, error: null);
    }
    return (success: false, cases: <SlaRiskCaseModel>[], error: res.error);
  }

  Future<({bool success, List<SlaRiskCaseModel> cases, String? error})> getBreachedCases() async {
    final res = await _api.getBreachedCases();
    if (res.success && res.data != null) {
      return (success: true, cases: res.data!, error: null);
    }
    return (success: false, cases: <SlaRiskCaseModel>[], error: res.error);
  }

  Future<({bool success, String? error})> escalateCase({
    required String caseId,
    required String reason,
    String escalationLevel = 'TEAM_LEAD',
  }) async {
    final res = await _api.escalateCase(caseId: caseId, reason: reason, escalationLevel: escalationLevel);
    if (res.success) {
      return (success: true, error: null);
    }
    return (success: false, error: res.error);
  }
}
