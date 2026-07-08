import '../../../shared/models/app_notification.dart';

abstract class NotificationRepository {
  Future<List<AppNotification>> getNotifications(String userId);

  Future<int> getUnreadCount(String userId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<void> deleteNotification(String notificationId);

  Stream<AppNotification> subscribeToNewNotifications(String userId);
}
