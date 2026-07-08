import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/pagination_notifier.dart';
import '../../../shared/models/app_notification.dart';
import '../providers/notification_provider.dart';

final paginatedNotificationsProvider = StateNotifierProvider.autoDispose.family<PaginatedNotificationsNotifier, PaginatedState<AppNotification>, String>((ref, userId) {
  return PaginatedNotificationsNotifier(ref, userId);
});

class PaginatedNotificationsNotifier extends PaginatedNotifier<AppNotification> {
  final Ref _ref;
  final String userId;

  PaginatedNotificationsNotifier(this._ref, this.userId);

  @override
  Future<List<AppNotification>> fetchPage(int page, int pageSize) async {
    final dataSource = _ref.read(notificationRemoteDataSourceProvider);
    return dataSource.getNotifications(userId, limit: pageSize, offset: page * pageSize);
  }
}
