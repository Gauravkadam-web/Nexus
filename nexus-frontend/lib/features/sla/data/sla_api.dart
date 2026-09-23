import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/sla_model.dart';

class SlaApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<CaseSlaModel>> getCaseSla(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseSla(caseId));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CaseSlaModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load SLA');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<SlaRiskCaseModel>>> getAtRiskCases() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.slaAtRisk);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => SlaRiskCaseModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load at-risk cases');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<SlaRiskCaseModel>>> getBreachedCases() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.slaBreached);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => SlaRiskCaseModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load breached cases');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> escalateCase({
    required String caseId,
    required String reason,
    String escalationLevel = 'TEAM_LEAD',
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseEscalate(caseId),
        data: {
          'reason': reason,
          'escalationLevel': escalationLevel,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to escalate case';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
