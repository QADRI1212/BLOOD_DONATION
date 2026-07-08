import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/models/app_notification.dart';
import '../services/notification_remote_datasource.dart';

final notificationRemoteDataSourceProvider = Provider<NotificationRemoteDataSource>((ref) {
  return NotificationRemoteDataSource(ref.read(cachedApiServiceProvider), SupabaseClientService());
});

final notificationsProvider = FutureProvider.family<List<AppNotification>, String>((ref, userId) async {
  final dataSource = ref.read(notificationRemoteDataSourceProvider);
  return dataSource.getNotifications(userId);
});

final unreadCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final dataSource = ref.read(notificationRemoteDataSourceProvider);
  return dataSource.getUnreadCount(userId);
});

final realtimeNotificationsProvider = StreamProvider.family<AppNotification, String>((ref, userId) {
  final dataSource = ref.read(notificationRemoteDataSourceProvider);
  return dataSource.subscribeToNewNotifications(userId);
});
