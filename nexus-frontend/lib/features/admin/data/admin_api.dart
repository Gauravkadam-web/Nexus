import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/admin_models.dart';

class AdminApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<AdminUserModel>>> getUsers() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.adminUsers);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => AdminUserModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load users');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> updateUserRole({
    required String userId,
    required String role,
  }) async {
    try {
      final response = await _client.dio.put(
        ApiEndpoints.adminUserRole(userId),
        data: {'role': role},
      );
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => json as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to update user role');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<SlaPolicyModel>>> getSlaPolicies() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.adminSlaPolicies);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => SlaPolicyModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load SLA policies');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<EscalationRuleModel>>> getEscalationRules() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.adminEscalationRules);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => EscalationRuleModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load escalation rules');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<CategoryModel>>> getCategories() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.categories);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load categories');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<TeamModel>>> getTeams() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.teams);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => TeamModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load teams');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
