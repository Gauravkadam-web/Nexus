import '../domain/investigation_model.dart';
import 'investigation_api.dart';

class InvestigationRepository {
  final InvestigationApi _api = InvestigationApi();

  Future<({bool success, List<InvestigationTaskModel> tasks, String? error})> getTasks(String caseId) async {
    final res = await _api.getTasks(caseId);
    if (res.success && res.data != null) {
      return (success: true, tasks: res.data!, error: null);
    }
    return (success: false, tasks: <InvestigationTaskModel>[], error: res.error);
  }

  Future<({bool success, InvestigationTaskModel? task, String? error})> createTask({
    required String caseId,
    required String title,
    String? assignedTo,
  }) async {
    final res = await _api.createTask(caseId: caseId, title: title, assignedTo: assignedTo);
    if (res.success && res.data != null) {
      return (success: true, task: res.data, error: null);
    }
    return (success: false, task: null, error: res.error);
  }

  Future<({bool success, InvestigationTaskModel? task, String? error})> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    final res = await _api.updateTaskStatus(taskId: taskId, status: status);
    if (res.success && res.data != null) {
      return (success: true, task: res.data, error: null);
    }
    return (success: false, task: null, error: res.error);
  }

  Future<({bool success, List<InvestigationRecordModel> records, String? error})> getInvestigations(String caseId) async {
    final res = await _api.getInvestigations(caseId);
    if (res.success && res.data != null) {
      return (success: true, records: res.data!, error: null);
    }
    return (success: false, records: <InvestigationRecordModel>[], error: res.error);
  }

  Future<({bool success, InvestigationRecordModel? record, String? error})> logInvestigation({
    required String caseId,
    required String summary,
    String? findings,
    String? hypothesis,
  }) async {
    final res = await _api.logInvestigation(
      caseId: caseId,
      summary: summary,
      findings: findings,
      hypothesis: hypothesis,
    );
    if (res.success && res.data != null) {
      return (success: true, record: res.data, error: null);
    }
    return (success: false, record: null, error: res.error);
  }
}
