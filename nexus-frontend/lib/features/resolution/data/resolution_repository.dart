import '../domain/resolution_model.dart';
import 'resolution_api.dart';

class ResolutionRepository {
  final ResolutionApi _api = ResolutionApi();

  Future<({bool success, ResolutionModel? resolution, String? error})> proposeResolution({
    required String caseId,
    required String summary,
    String? rootCause,
    String? resolutionAction,
    String? preventiveAction,
  }) async {
    final res = await _api.proposeResolution(
      caseId: caseId,
      summary: summary,
      rootCause: rootCause,
      resolutionAction: resolutionAction,
      preventiveAction: preventiveAction,
    );
    if (res.success && res.data != null) {
      return (success: true, resolution: res.data, error: null);
    }
    return (success: false, resolution: null, error: res.error);
  }

  Future<({bool success, ResolutionModel? resolution, String? error})> confirmResolution(String caseId) async {
    final res = await _api.confirmResolution(caseId);
    if (res.success && res.data != null) {
      return (success: true, resolution: res.data, error: null);
    }
    return (success: false, resolution: null, error: res.error);
  }

  Future<({bool success, ResolutionModel? resolution, String? error})> rejectResolution({
    required String caseId,
    required String rejectionReason,
  }) async {
    final res = await _api.rejectResolution(caseId: caseId, rejectionReason: rejectionReason);
    if (res.success && res.data != null) {
      return (success: true, resolution: res.data, error: null);
    }
    return (success: false, resolution: null, error: res.error);
  }
}
