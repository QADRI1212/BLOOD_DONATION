import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../features/blood_requests/providers/blood_request_provider.dart';
import '../providers/admin_provider.dart';

class AdminRequestsScreen extends ConsumerStatefulWidget {
  const AdminRequestsScreen({super.key});

  @override
  ConsumerState<AdminRequestsScreen> createState() => _AdminRequestsScreenState();
}

class _AdminRequestsScreenState extends ConsumerState<AdminRequestsScreen> {
  @override
  Widget build(BuildContext context) {
    final requestsAsync = ref.watch(adminRequestsProvider(null));
    final currentLocale = ref.watch(localeProvider);

    // Listen for real-time blood request changes and auto-refresh the list
    ref.listen(realtimeRequestsProvider, (_, next) {
      next.whenOrNull(data: (_) {
        if (!mounted) return;
        ref.invalidate(adminRequestsProvider(null));
      });
    });

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('manageRequestsTitle', currentLocale)),
      body: requestsAsync.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocalizationService.tr('failedToLoadRequests', currentLocale).replaceAll('{error}', '$e')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(adminRequestsProvider(null)),
                child: Text(LocalizationService.tr('retry', currentLocale)),
              ),
            ],
          ),
        ),
        data: (requests) {
          if (requests.isEmpty) {
            return EmptyState(
              icon: Icons.assignment_outlined,
              title: LocalizationService.tr('noRequestsAdmin', currentLocale),
              subtitle: LocalizationService.tr('requestsWillAppear', currentLocale),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminRequestsProvider(null));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return _AdminRequestCard(request: request);
              },
            ),
          );
        },
      ),
    );
  }
}

class _AdminRequestCard extends ConsumerWidget {
  final BloodRequest request;

  const _AdminRequestCard({required this.request});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final statusColor = switch (request.status) {
      'pending' => AppColors.warning,
      'accepted' => AppColors.info,
      'completed' => AppColors.success,
      'cancelled' => AppColors.grey500,
      _ => AppColors.grey500,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bloodtype_rounded, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        LocalizationService.tr('bloodGroupBlood', currentLocale).replaceAll('{bloodGroup}', request.bloodGroup),
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (request.patientName != null)
                        Text(
                          '${LocalizationService.tr('patientLabel', currentLocale)}: ${request.patientName}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (request.status != 'cancelled')
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(LocalizationService.tr('removeRequest', currentLocale)),
                          content: Text(LocalizationService.tr('removeRequestConfirm', currentLocale)),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LocalizationService.tr('cancel', currentLocale))),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(LocalizationService.tr('remove', currentLocale), style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        await ref.read(adminNotifierProvider.notifier).removeRequest(request.id);
                        ref.invalidate(adminRequestsProvider(null));
                      }
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: Text(LocalizationService.tr('remove', currentLocale)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
