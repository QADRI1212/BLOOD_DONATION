import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/cached_api_service.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/app_notification.dart';

class NotificationRemoteDataSource {
  static const String _cacheBox = 'cached_notifications';
  final CachedApiService _api;
  final SupabaseClientService _supabase;
  final LoggerService _logger = LoggerService();

  NotificationRemoteDataSource(this._api, this._supabase);

  Future<List<AppNotification>> getNotifications(String userId, {int? limit, int? offset}) async {
    try {
      final data = await _api.query(
        'notifications',
        cacheBox: _cacheBox,
        column: 'user_id',
        value: userId,
        orderBy: 'created_at',
        ascending: false,
        limit: limit,
        offset: offset,
      );
      return data.map((e) => AppNotification.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get notifications', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final data = await _api.query(
        'notifications',
        cacheBox: _cacheBox,
        filters: {'user_id': userId, 'is_read': false},
      );
      return data.length;
    } catch (e, stack) {
      _logger.error('Failed to get unread count', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _api.update(
        'notifications',
        {'is_read': true},
        'id',
        notificationId,
      );
    } catch (e, stack) {
      _logger.error('Failed to mark notification as read', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _api.update(
        'notifications',
        {'is_read': true},
        'user_id',
        userId,
      );
    } catch (e, stack) {
      _logger.error('Failed to mark all as read', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _api.delete('notifications', 'id', notificationId);
    } catch (e, stack) {
      _logger.error('Failed to delete notification', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Stream<AppNotification> subscribeToNewNotifications(String userId) {
    final controller = StreamController<AppNotification>();

    try {
      final channel = _supabase.client.channel('public:notifications');

      channel.onPostgresChanges(
        table: 'notifications',
        schema: 'public',
        event: PostgresChangeEvent.insert,
        callback: (payload) {
          final record = Map<String, dynamic>.from(
            payload.newRecord as Map,
          );
          final notification = AppNotification.fromJson(record);

          if (notification.userId == userId) {
            controller.add(notification);
          }
        },
      );

      channel.subscribe();
    } catch (e, stack) {
      _logger.error('Failed to subscribe to notifications', error: e, stackTrace: stack);
    }

    return controller.stream;
  }
}
