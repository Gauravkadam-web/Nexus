import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/api_response.dart';
import '../domain/notification_model.dart';

class NotificationApi {
  final ApiClient _client = ApiClient();

  Future<ApiResponse<List<NotificationModel>>> getMyNotifications() async {
    try {
      final response = await _client.dio.get('notifications/my');
      final data = response.data['data'];
      List<dynamic> rawList = [];
      if (data is Map<String, dynamic> && data['content'] is List) {
        rawList = data['content'] as List<dynamic>;
      } else if (data is List) {
        rawList = data;
      }
      final list = rawList.map((e) => NotificationModel.fromJson(e as Map<String, dynamic>)).toList();
      return ApiResponse(success: true, data: list);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to load notifications');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _client.dio.get('notifications/unread-count');
      final count = (response.data['data']?['unreadCount'] as num?)?.toInt() ?? 0;
      return ApiResponse(success: true, data: count);
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<bool>> markAsRead(String id) async {
    try {
      await _client.dio.patch(ApiEndpoints.notificationRead(id));
      return const ApiResponse(success: true, data: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to mark as read');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }

  Future<ApiResponse<bool>> markAllAsRead() async {
    try {
      await _client.dio.patch(ApiEndpoints.notificationsReadAll);
      return const ApiResponse(success: true, data: true);
    } on DioException catch (e) {
      return ApiResponse(success: false, error: e.message ?? 'Failed to mark all as read');
    } catch (e) {
      return ApiResponse(success: false, error: e.toString());
    }
  }
}
