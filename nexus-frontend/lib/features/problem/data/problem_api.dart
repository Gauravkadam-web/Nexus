import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/problem_model.dart';

class ProblemApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<ProblemModel>>> getProblems() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.problems);
      final rawList = ApiResponse.extractList(response.data['data']);
      final list = rawList.map((e) => ProblemModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load problems');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<ProblemModel>> getProblemDetail(String id) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.problemDetail(id));
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => ProblemModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load problem detail');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<RecurringPatternModel>>> getRecurringPatterns() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.problemRecurringPatterns);
      final rawList = ApiResponse.extractList(response.data['data']);
      final list = rawList.map((e) => RecurringPatternModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load patterns');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<bool>> linkIncident({
    required String problemId,
    required String caseId,
  }) async {
    try {
      await _client.dio.post(
        ApiEndpoints.problemIncidents(problemId),
        data: {'caseId': caseId},
      );
      return const ApiResponse(success: true, data: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to link incident');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
