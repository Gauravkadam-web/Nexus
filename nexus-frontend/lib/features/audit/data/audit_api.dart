import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/audit_model.dart';

class AuditApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<AuditLogModel>>> getAuditLogs() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.auditLogs);
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load audit logs');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<AuditLogModel>>> getCaseTimeline(String caseId) async {
    try {
      final response = await _client.dio.get(ApiEndpoints.auditLogCaseTimeline(caseId));
      final rawList = response.data['data'] as List<dynamic>? ?? [];
      final list = rawList.map((e) => AuditLogModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load case timeline');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
