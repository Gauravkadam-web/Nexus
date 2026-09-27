import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/investigation_model.dart';

class InvestigationApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<InvestigationTaskModel>>> getTasks(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseTasks(caseId));
      final rawList = ApiResponse.extractList(response.data['data']);
      final list = rawList.map((e) => InvestigationTaskModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load tasks');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<InvestigationTaskModel>> createTask({
    required String caseId,
    required String title,
    String? assignedTo,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseTasks(caseId),
        data: {
          'title': title,
          'assignedTo': assignedTo,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => InvestigationTaskModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to create task';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<InvestigationTaskModel>> updateTaskStatus({
    required String taskId,
    required String status,
  }) async {
    try {
      final response = await _client.dio.patch(
        ApiEndpoints.taskStatus(taskId),
        data: {'status': status},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => InvestigationTaskModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to update task');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<InvestigationRecordModel>>> getInvestigations(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.caseInvestigations(caseId));
      final rawList = ApiResponse.extractList(response.data['data']);
      final list = rawList.map((e) => InvestigationRecordModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load investigations');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<InvestigationRecordModel>> logInvestigation({
    required String caseId,
    required String summary,
    String? findings,
    String? hypothesis,
  }) async {
    try {
      final response = await _client.dio.post(
        ApiEndpoints.caseInvestigations(caseId),
        data: {
          'summary': summary,
          'findings': findings,
          'hypothesis': hypothesis,
        },
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => InvestigationRecordModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = e.response?.data?['error'] as String? ?? e.message ?? 'Failed to log investigation';
      return ApiResponse(success: false, error: msg);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
