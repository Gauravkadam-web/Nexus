import '../domain/copilot_model.dart';
import 'copilot_api.dart';

class CopilotRepository {
  final CopilotApi _api = CopilotApi();

  Future<({bool success, CopilotQueryResponse? response, String? error})> queryCopilot({
    required String caseId,
    required String prompt,
  }) async {
    final res = await _api.queryCopilot(caseId: caseId, prompt: prompt);
    if (res.success && res.data != null) {
      return (success: true, response: res.data, error: null);
    }
    return (success: false, response: null, error: res.error);
  }

  Future<({bool success, CommunicationDraftResponse? draft, String? error})> draftCommunication({
    required String caseId,
    required String audience,
    required String tone,
    String? additionalNotes,
  }) async {
    final res = await _api.draftCommunication(
      caseId: caseId,
      audience: audience,
      tone: tone,
      additionalNotes: additionalNotes,
    );
    if (res.success && res.data != null) {
      return (success: true, draft: res.data, error: null);
    }
    return (success: false, draft: null, error: res.error);
  }
}
