import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/resolution_model.dart';

class ResolutionApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<ResolutionModel>> getResolution(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseResolution(caseId));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ResolutionModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to fetch resolution';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<ResolutionModel>> getProposal(String caseId) => getResolution(caseId);

  Future<ApiResponse<ResolutionModel>> proposeResolution({
    required String caseId,
    required String summary,
    String? rootCause,
    String? resolutionAction,
    String? preventiveAction,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseResolution(caseId),
        data: {
          'summary': summary,
          'rootCause': rootCause,
          'resolutionAction': resolutionAction,
          'preventiveAction': preventiveAction,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ResolutionModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to propose resolution';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<ResolutionModel>> confirmResolution(String caseId) async {
    try {
      final response = await _client.dio.post(ApiEndpoints.caseResolutionConfirm(caseId));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ResolutionModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to confirm resolution';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<ResolutionModel>> rejectResolution({
    required String caseId,
    required String rejectionReason,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseResolutionReject(caseId),
        data: {'rejectionReason': rejectionReason},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ResolutionModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to reject resolution';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
