import '../domain/notification_model.dart';
import 'notification_api.dart';

class NotificationRepository {
  final NotificationApi _api = NotificationApi();

  Future<({bool success, List<NotificationModel> notifications, String? error})> getMyNotifications() async {
    final res = await _api.getMyNotifications();
    if (res.success && res.data != null) {
      return (success: true, notifications: res.data!, error: null);
    }
    return (success: false, notifications: <NotificationModel>[], error: res.error);
  }

  Future<int> getUnreadCount() async {
    final res = await _api.getUnreadCount();
    return res.data ?? 0;
  }

  Future<bool> markAsRead(String id) async {
    final res = await _api.markAsRead(id);
    return res.success;
  }

  Future<bool> markAllAsRead() async {
    final res = await _api.markAllAsRead();
    return res.success;
  }
}
