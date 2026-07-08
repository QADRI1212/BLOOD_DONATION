import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider(null));
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('manageUsersTitle', currentLocale)),
      body: usersAsync.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocalizationService.tr('failedToLoad', currentLocale).replaceAll('{error}', '$e')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(adminUsersProvider(null)),
                child: Text(LocalizationService.tr('retry', currentLocale)),
              ),
            ],
          ),
        ),
        data: (users) {
          if (users.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline_rounded,
              title: LocalizationService.tr('noUsersYet', currentLocale),
              subtitle: LocalizationService.tr('usersWillAppear', currentLocale),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminUsersProvider(null));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return _UserCard(user: user);
              },
            ),
          );
        },
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  final UserProfile user;

  const _UserCard({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final roleColors = switch (user.role) {
      'admin' => AppColors.accent,
      'donor' => AppColors.primary,
      'patient' => AppColors.info,
      _ => AppColors.grey500,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: roleColors.withValues(alpha: 0.2),
          child: Text(
            user.initials,
            style: TextStyle(color: roleColors, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(user.name, style: AppTypography.titleMedium),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, style: AppTypography.bodySmall),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: roleColors.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: roleColors,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (user.bloodGroup != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      user.bloodGroup!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.block_rounded, color: AppColors.error, size: 20),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(LocalizationService.tr('suspendUser', currentLocale)),
                content: Text(LocalizationService.tr('suspendUserConfirm', currentLocale).replaceAll('{name}', user.name)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LocalizationService.tr('cancel', currentLocale))),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(LocalizationService.tr('suspend', currentLocale), style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await ref.read(adminNotifierProvider.notifier).suspendUser(user.id);
              ref.invalidate(adminUsersProvider(null));
            }
          },
        ),
      ),
    );
  }
}
