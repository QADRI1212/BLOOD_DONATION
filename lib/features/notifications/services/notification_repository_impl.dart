import 'dart:async';
import '../../../core/network/api_service.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/models/app_notification.dart';
import './notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final SupabaseClientService _supabase;
  final ApiService _api;

  NotificationRepositoryImpl(this._supabase, this._api);

  @override
  Future<List<AppNotification>> getNotifications(String userId) async {
    final data = await _api.query(
      'notifications',
      column: 'user_id',
      value: userId,
      orderBy: 'created_at',
      ascending: false,
    );
    return data.map((e) => AppNotification.fromJson(e)).toList();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    final data = await _supabase.client
        .from('notifications')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _api.update(
      'notifications',
      {'is_read': true},
      'id',
      notificationId,
    );
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await _supabase.client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _api.delete('notifications', 'id', notificationId);
  }

  @override
  Stream<AppNotification> subscribeToNewNotifications(String userId) {
    final controller = StreamController<AppNotification>.broadcast();
    return controller.stream;
  }
}
