import '../domain/analytics_models.dart';
import 'analytics_api.dart';

class AnalyticsRepository {
  final AnalyticsApi _api = AnalyticsApi();

  Future<({bool success, AnalyticsOverviewModel? overview, String? error})> getOverview() async {
    final res = await _api.getOverview();
    if (res.success && res.data != null) {
      return (success: true, overview: res.data, error: null);
    }
    return (success: false, overview: null, error: res.error);
  }

  Future<({bool success, List<VolumeTrendModel> trends, String? error})> getVolumeTrends({int days = 7}) async {
    final res = await _api.getVolumeTrends(days: days);
    if (res.success && res.data != null) {
      return (success: true, trends: res.data!, error: null);
    }
    return (success: false, trends: <VolumeTrendModel>[], error: res.error);
  }

  Future<({bool success, List<OperationalInsightModel> insights, String? error})> getOperationalInsights() async {
    final res = await _api.getOperationalInsights();
    if (res.success && res.data != null) {
      return (success: true, insights: res.data!, error: null);
    }
    return (success: false, insights: <OperationalInsightModel>[], error: res.error);
  }
}
