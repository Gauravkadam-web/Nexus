import '../domain/audit_model.dart';
import 'audit_api.dart';

class AuditRepository {
  final AuditApi _api = AuditApi();

  Future<({bool success, List<AuditLogModel> logs, String? error})> getAuditLogs() async {
    final res = await _api.getAuditLogs();
    if (res.success && res.data != null) {
      return (success: true, logs: res.data!, error: null);
    }
    return (success: false, logs: <AuditLogModel>[], error: res.error);
  }

  Future<({bool success, List<AuditLogModel> timeline, String? error})> getCaseTimeline(String caseId) async {
    final res = await _api.getCaseTimeline(caseId);
    if (res.success && res.data != null) {
      return (success: true, timeline: res.data!, error: null);
    }
    return (success: false, timeline: <AuditLogModel>[], error: res.error);
  }
}
