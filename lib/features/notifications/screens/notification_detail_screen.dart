import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/app_notification.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../providers/notification_provider.dart';
import '../providers/paginated_notifications_provider.dart';

class NotificationDetailScreen extends ConsumerWidget {
  final AppNotification notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('notification', currentLocale),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'delete') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(LocalizationService.tr('deleteNotification', currentLocale)),
                    content: Text(LocalizationService.tr('deleteNotificationConfirm', currentLocale)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LocalizationService.tr('cancel', currentLocale))),
                      TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(LocalizationService.tr('delete', currentLocale))),
                    ],
                  ),
                );
                if (confirmed == true) {
                  final dataSource = ref.read(notificationRemoteDataSourceProvider);
                  await dataSource.deleteNotification(notification.id);
                  ref.invalidate(paginatedNotificationsProvider(notification.userId));
                  ref.invalidate(unreadCountProvider(notification.userId));
                  if (context.mounted) context.pop();
                }
              } else if (value == 'share') {
                _shareNotification(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'share', child: ListTile(leading: const Icon(Icons.share), title: Text(LocalizationService.tr('share', currentLocale)))),
              PopupMenuItem(value: 'delete', child: ListTile(leading: const Icon(Icons.delete_outline, color: AppColors.error), title: Text(LocalizationService.tr('delete', currentLocale)))),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeader(context, currentLocale),
          const SizedBox(height: 24),
          _buildBody(context, currentLocale),
          const SizedBox(height: 24),
          if (_getActionButtonConfig(currentLocale) != null) _buildActionButton(context, currentLocale),
          if (_getActionButtonConfig(currentLocale) != null) const SizedBox(height: 16),
          _buildMetadata(context, currentLocale),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String currentLocale) {
    final (icon, color) = _getTypeIconAndColor();
    final now = DateTime.now();
    final diff = now.difference(notification.createdAt);

    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeAgo = '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      timeAgo = '${diff.inDays}d ago';
    } else {
      timeAgo = '${notification.createdAt.month}/${notification.createdAt.day}/${notification.createdAt.year}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _getTypeLabel(currentLocale),
                      style: AppTypography.labelMedium.copyWith(color: color),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeAgo,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.grey400),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          notification.title,
          style: AppTypography.headlineMedium,
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, String currentLocale) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [            Text(
              LocalizationService.tr('details', currentLocale),
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.grey500,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 12),
          Text(
            notification.body,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.grey800,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String currentLocale) {
    final config = _getActionButtonConfig(currentLocale)!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: config.color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: () => config.onPressed(context),
        icon: Icon(config.icon, size: 20),
        label: Text(config.label, style: AppTypography.buttonMedium),
      ),
    );
  }

  Widget _buildMetadata(BuildContext context, String currentLocale) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(LocalizationService.tr('details', currentLocale), style: AppTypography.titleSmall.copyWith(color: AppColors.grey500)),
          const SizedBox(height: 12),
          _metadataRow(LocalizationService.tr('type', currentLocale), _getTypeLabel(currentLocale)),
          if (notification.relatedType != null)
            _metadataRow(LocalizationService.tr('relatedTo', currentLocale), notification.relatedType!.replaceAll('_', ' ').toUpperCase()),            _metadataRow(LocalizationService.tr('received', currentLocale), _formatFullDate(notification.createdAt, currentLocale)),
          _metadataRow(LocalizationService.tr('status', currentLocale), notification.isRead ? LocalizationService.tr('read', currentLocale) : LocalizationService.tr('unread', currentLocale)),
        ],
      ),
    );
  }

  Widget _metadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500)),
          Text(value, style: AppTypography.bodyMedium.copyWith(color: AppColors.grey800, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  (IconData, Color) _getTypeIconAndColor() {
    switch (notification.type) {
      case 'emergency':
        return (Icons.emergency_rounded, AppColors.error);
      case 'reminder':
        return (Icons.notifications_active_rounded, AppColors.warning);
      case 'announcement':
        return (Icons.campaign_rounded, AppColors.info);
      default:
        return (Icons.notifications_rounded, AppColors.primary);
    }
  }

  String _getTypeLabel(String currentLocale) {
    switch (notification.type) {
      case 'emergency':
        return LocalizationService.tr('emergencyAlert', currentLocale);
      case 'reminder':
        return LocalizationService.tr('reminder', currentLocale);
      case 'announcement':
        return LocalizationService.tr('announcement', currentLocale);
      default:
        return LocalizationService.tr('general', currentLocale);
    }
  }

  _ActionButtonConfig? _getActionButtonConfig(String currentLocale) {
    switch (notification.relatedType) {
      case 'blood_request':
        return _ActionButtonConfig(
          label: LocalizationService.tr('viewRequestDetails', currentLocale),
          icon: Icons.bloodtype_rounded,
          color: AppColors.primary,
          onPressed: (context) => context.push('/requests/${notification.relatedId}'),
        );
      case 'hospital':
        return _ActionButtonConfig(
          label: LocalizationService.tr('viewHospital', currentLocale),
          icon: Icons.local_hospital_rounded,
          color: AppColors.secondary,
          onPressed: (context) => context.push('/hospitals'),
        );
      case 'blood_bank':
        return _ActionButtonConfig(
          label: LocalizationService.tr('viewBloodBank', currentLocale),
          icon: Icons.biotech_rounded,
          color: AppColors.secondary,
          onPressed: (context) => context.push('/blood-banks'),
        );
      case 'profile':
        return _ActionButtonConfig(
          label: LocalizationService.tr('viewProfile', currentLocale),
          icon: Icons.person_rounded,
          color: AppColors.accent,
          onPressed: (context) => context.push('/donors'),
        );
      case 'announcement':
        return _ActionButtonConfig(
          label: LocalizationService.tr('viewFullAnnouncement', currentLocale),
          icon: Icons.campaign_rounded,
          color: AppColors.info,
          onPressed: (_) {},
        );
      default:
        return null;
    }
  }

  void _shareNotification(BuildContext context) {
    // In production, use share_plus package to share notification content
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(LocalizationService.tr('notificationCopied', 'en')),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatFullDate(DateTime date, String currentLocale) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final amPm = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '${months[date.month - 1]} ${date.day}, ${date.year} at $hour:$minute $amPm';
  }
}

class _ActionButtonConfig {
  final String label;
  final IconData icon;
  final Color color;
  final void Function(BuildContext context) onPressed;

  _ActionButtonConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}
