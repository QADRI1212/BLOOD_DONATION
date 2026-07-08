import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class AdminReportsScreen extends ConsumerWidget {
  const AdminReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We reuse the admin data source via the requests provider pattern
    final reportsAsync = ref.watch(adminReportsProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('userReports', currentLocale),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(adminReportsProvider),
            tooltip: LocalizationService.tr('refresh', currentLocale),
          ),
        ],
      ),
      body: reportsAsync.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
              const SizedBox(height: 16),
              Text(LocalizationService.tr('failedToLoadReports', currentLocale).replaceAll('{error}', '$e'), style: AppTypography.titleMedium),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => ref.invalidate(adminReportsProvider),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(LocalizationService.tr('retry', currentLocale)),
              ),
            ],
          ),
        ),
        data: (reports) {
          if (reports.isEmpty) {
            return EmptyState(
              icon: Icons.flag_outlined,
              title: LocalizationService.tr('noReports', currentLocale),
              subtitle: LocalizationService.tr('reportsWillAppear', currentLocale),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminReportsProvider);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return _ReportCard(
                  report: report,
                  onDismiss: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(LocalizationService.tr('dismissReport', currentLocale)),
                        content: Text(LocalizationService.tr('dismissReportConfirm', currentLocale)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LocalizationService.tr('cancel', currentLocale))),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(LocalizationService.tr('dismiss', currentLocale), style: TextStyle(color: AppColors.success)),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      ref.read(adminNotifierProvider.notifier).dismissReport(report['id'] as String);
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

class _ReportCard extends ConsumerWidget {
  final Map<String, dynamic> report;
  final VoidCallback onDismiss;

  const _ReportCard({required this.report, required this.onDismiss});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    // Reporter and reported names are now enriched by the data source
    final reporterName = report['reporter_name'] as String? ?? LocalizationService.tr('unknownUser', currentLocale);
    final reportedUser = report['reported_name'] as String? ?? LocalizationService.tr('unknownUser', currentLocale);
    final reason = report['reason'] as String? ?? LocalizationService.tr('noReasonProvided', currentLocale);
    final status = report['status'] as String? ?? 'pending';
    final createdAt = report['created_at'] as String? ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                    color: AppColors.errorContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.flag_rounded, color: AppColors.error, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(LocalizationService.tr('reportedUser', currentLocale), style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                      Text(reportedUser, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: status == 'pending'
                        ? AppColors.warningContainer
                        : AppColors.successContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: AppTypography.labelSmall.copyWith(
                      color: status == 'pending' ? AppColors.warning : AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(LocalizationService.tr('reason', currentLocale).replaceAll('{reason}', reason), style: AppTypography.bodyMedium),
            const SizedBox(height: 4),
            Text(LocalizationService.tr('reportedBy', currentLocale).replaceAll('{name}', reporterName), style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
            if (createdAt.isNotEmpty)
              Text(LocalizationService.tr('date', currentLocale).replaceAll('{date}', createdAt.substring(0, 10)), style: AppTypography.bodySmall.copyWith(color: AppColors.grey400)),
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    onPressed: onDismiss,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(LocalizationService.tr('dismiss', currentLocale)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.success,
                      side: const BorderSide(color: AppColors.success),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
