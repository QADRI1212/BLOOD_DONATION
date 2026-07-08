import '../../../shared/models/app_notification.dart';
import './notification_repository.dart';

class NotificationUseCases {
  final NotificationRepository _repository;

  NotificationUseCases(this._repository);

  Future<List<AppNotification>> getNotifications(String userId) {
    return _repository.getNotifications(userId);
  }

  Future<int> getUnreadCount(String userId) {
    return _repository.getUnreadCount(userId);
  }

  Future<void> markAsRead(String notificationId) {
    return _repository.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) {
    return _repository.markAllAsRead(userId);
  }

  Future<void> deleteNotification(String notificationId) {
    return _repository.deleteNotification(notificationId);
  }

  Stream<AppNotification> subscribeToNewNotifications(String userId) {
    return _repository.subscribeToNewNotifications(userId);
  }
}
