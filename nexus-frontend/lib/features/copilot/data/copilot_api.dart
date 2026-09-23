import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/copilot_model.dart';

class CopilotApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<CopilotQueryResponse>> queryCopilot({
    required String caseId,
    String? prompt,
    String? query,
  }) async {
    try {
      final effectivePrompt = prompt ?? query ?? '';
      final response = await _client.dio.post(
        ApiEndpoints.aiCopilot(caseId),
        data: {'prompt': effectivePrompt, 'query': effectivePrompt},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CopilotQueryResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Copilot query failed';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<CommunicationDraftResponse>> draftCommunication({
    required String caseId,
    required String audience,
    required String tone,
    String? additionalNotes,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.aiDraftComm(caseId),
        data: {
          'audience': audience,
          'tone': tone,
          'additionalNotes': additionalNotes,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CommunicationDraftResponse.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to generate draft';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
