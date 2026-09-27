import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/analytics_models.dart';

class AnalyticsApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<AnalyticsOverviewModel>> getOverview() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.analyticsOverview);
      return ApiResponse.fromJson(
        response.data as Map<String, dynamic>,
        (json) => AnalyticsOverviewModel.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load analytics overview');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<VolumeTrendModel>>> getVolumeTrends({int days = 7}) async {
    try {
      final response = await _client.dio.get('${ApiEndpoints.analyticsTrends}?days=$days');
      final rawList = ApiResponse.extractList(response.data['data']);
      final list = rawList.map((e) => VolumeTrendModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load volume trends');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<List<OperationalInsightModel>>> getOperationalInsights() async {
    try {
      final response = await _client.dio.get(ApiEndpoints.analyticsOperationalInsights);
      final rawList = ApiResponse.extractList(response.data['data']);
      final list = rawList.map((e) => OperationalInsightModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load operational insights');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
