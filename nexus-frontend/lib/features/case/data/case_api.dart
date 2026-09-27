import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/case_model.dart';

class CaseApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<CaseModel>>> getMyCases() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.myCases);
      final rawList = ApiResponse.extractList(response.data['data']);
      final cases = rawList.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: cases);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load cases');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<CaseModel>>> getAssignedCases() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.assignedCases);
      final rawList = ApiResponse.extractList(response.data['data']);
      final cases = rawList.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: cases);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load assigned cases');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<CaseModel>>> getTeamCases() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.teamCases);
      final rawList = ApiResponse.extractList(response.data['data']);
      final cases = rawList.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: cases);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load team cases');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<CaseModel>> getCaseDetail(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseDetail(id));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CaseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load case detail');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<CaseModel>> createCase({
    required String title,
    required String description,
    required String categoryId,
    required String severity,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.cases,
        data: {
          'title': title,
          'description': description,
          'categoryId': categoryId,
          'severity': severity,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CaseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to create case';
      return ApiResponse(success: false, error: errorMsg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<CaseModel>> updateCaseStatus({
    required String id,
    required String status,
  }) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.caseStatus(id),
        data: {'status': status},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CaseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to update status';
      return ApiResponse(success: false, error: errorMsg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<CaseModel>> assignCase({
    required String id,
    required String operatorId,
    String? teamId,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseAssign(id),
        data: {
          'assignedTo': operatorId,
          'teamId': teamId,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CaseModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to assign case';
      return ApiResponse(success: false, error: errorMsg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<CaseModel>>> searchCases({
    String? query,
    String? status,
    String? severity,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null && query.isNotEmpty) queryParams['query'] = query;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (severity != null && severity.isNotEmpty) queryParams['severity'] = severity;
      if (categoryId != null && categoryId.isNotEmpty) queryParams['categoryId'] = categoryId;

      final response = await _client.dio.get(
        ApiEndpoints.caseSearch,
        queryParameters: queryParams,
      );
      final rawList = ApiResponse.extractList(response.data['data']);
      final cases = rawList.map((e) => CaseModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: cases);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Search failed');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAiAnalysis(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.aiAnalysis(caseId));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load AI analysis');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAiSummary(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.aiSummary(caseId));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load AI summary');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<bool>> decideAiSuggestion({
    required String suggestionId,
    required String decision, // ACCEPTED, MODIFIED, REJECTED
    String? modifiedValue,
  }) async {
    try {
      await _client.dio.put(
        ApiEndpoints.aiSuggestionDecision(suggestionId),
        data: {
          'decision': decision,
          'modifiedValue': modifiedValue,
        },
      );
      return const ApiResponse(success: true, data: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to record AI suggestion decision');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
