import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../providers/notification_provider.dart';
import '../providers/paginated_notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = ref.read(authProvider).valueOrNull?.id;
      if (userId != null) {
        ref.read(paginatedNotificationsProvider(userId).notifier).loadFirstPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final userId = ref.read(authProvider).valueOrNull?.id;
      if (userId != null) {
        ref.read(paginatedNotificationsProvider(userId).notifier).loadNextPage();
      }
    }
  }

  void _navigateToDetail(AppNotification notification) {
    context.push('/notifications/detail', extra: notification);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.valueOrNull?.id;

    final unreadCountAsync = userId != null ? ref.watch(unreadCountProvider(userId)) : null;
    final paginatedState = userId != null ? ref.watch(paginatedNotificationsProvider(userId)) : null;

    // Listen for real-time notifications
    if (userId != null) {
      ref.listen(realtimeNotificationsProvider(userId), (_, next) {
        next.whenOrNull(data: (notification) {
          if (!mounted) return;
          ref.invalidate(paginatedNotificationsProvider(userId));
          ref.invalidate(unreadCountProvider(userId));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          notification.body,
                          style: const TextStyle(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'View',
                onPressed: () {
                  _navigateToDetail(notification);
                },
              ),
            ),
          );
        });
      });
    }

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('notifications', currentLocale),
        actions: [
          if (unreadCountAsync != null)
            unreadCountAsync.when(
              data: (count) => count > 0
                  ? TextButton(
                      onPressed: () async {
                        final userId = ref.read(authProvider).valueOrNull?.id;
                        if (userId != null) {
                          final dataSource = ref.read(notificationRemoteDataSourceProvider);
                          await dataSource.markAllAsRead(userId);
                          ref.invalidate(paginatedNotificationsProvider(userId));
                          ref.invalidate(unreadCountProvider(userId));
                        }
                      },
                      child: Text(LocalizationService.tr('markAllRead', currentLocale).replaceAll('{count}', '$count')),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
        ],
      ),
      body: authState.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null || paginatedState == null) {
            return const EmptyState(icon: Icons.error_outline, title: 'Please sign in');
          }

          if (paginatedState.isLoading) return const ListShimmer();
          if (paginatedState.error != null && paginatedState.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
                  const SizedBox(height: 16),
                  Text(LocalizationService.tr('failedToLoadNotifications', currentLocale), style: AppTypography.titleMedium),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.read(paginatedNotificationsProvider(userId!).notifier).refresh(),
                    child: Text(LocalizationService.tr('retry', currentLocale)),
                  ),
                ],
              ),
            );
          }

          if (paginatedState.items.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none_rounded,
              title: LocalizationService.tr('noNotifications', currentLocale),
              subtitle: LocalizationService.tr('noNotificationsDesc', currentLocale),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(paginatedNotificationsProvider(userId!).notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: paginatedState.items.length + (paginatedState.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == paginatedState.items.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                final notification = paginatedState.items[index];
                final uid = user.id;
                return _NotificationCard(
                  notification: notification,
                  onTap: () {
                    _navigateToDetail(notification);
                  },
                  onRead: () async {
                    if (!notification.isRead) {
                      final dataSource = ref.read(notificationRemoteDataSourceProvider);
                      await dataSource.markAsRead(notification.id);
                      ref.invalidate(paginatedNotificationsProvider(uid));
                      ref.invalidate(unreadCountProvider(uid));
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onRead;

  const _NotificationCard({required this.notification, required this.onTap, required this.onRead});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case 'emergency':
        icon = Icons.emergency_rounded;
        color = AppColors.error;
        break;
      case 'reminder':
        icon = Icons.notifications_active_rounded;
        color = AppColors.warning;
        break;
      case 'announcement':
        icon = Icons.campaign_rounded;
        color = AppColors.info;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.primary;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 0.5 : 2,
      color: notification.isRead ? null : AppColors.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead
            ? BorderSide.none
            : BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          onRead();
          onTap();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTime(notification.createdAt),
                      style: AppTypography.labelSmall.copyWith(color: AppColors.grey400),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
