import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/donation.dart';
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

class _AdminRequestsScreenState extends ConsumerState<AdminRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    // Listen for real-time blood request changes and auto-refresh
    ref.listen(realtimeRequestsProvider, (_, next) {
      next.whenOrNull(data: (_) {
        if (!mounted) return;
        ref.invalidate(adminPendingRequestsProvider);
        ref.invalidate(adminAcceptedRequestsProvider);
        ref.invalidate(adminDonationsHistoryProvider);
      });
    });

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('manageRequestsTitle', currentLocale),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey500,
          tabs: [
            Tab(
              icon: const Icon(Icons.hourglass_empty_rounded),
              text: LocalizationService.tr('pendingTab', currentLocale),
            ),
            Tab(
              icon: const Icon(Icons.pending_actions_rounded),
              text: LocalizationService.tr('activeTab', currentLocale),
            ),
            Tab(
              icon: const Icon(Icons.history_rounded),
              text: LocalizationService.tr('donationHistoryTab', currentLocale),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingRequestsTab(),
          _AcceptedRequestsTab(),
          _DonationHistoryTab(),
        ],
      ),
    );
  }
}

class _PendingRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(adminPendingRequestsProvider);
    final currentLocale = ref.watch(localeProvider);

    return requestsAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocalizationService.tr('failedToLoadRequests', currentLocale).replaceAll('{error}', '$e')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(adminPendingRequestsProvider),
              child: Text(LocalizationService.tr('retry', currentLocale)),
            ),
          ],
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return EmptyState(
            icon: Icons.hourglass_empty_rounded,
            title: LocalizationService.tr('noPendingRequests', currentLocale),
            subtitle: LocalizationService.tr('noPendingRequestsDesc', currentLocale),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminPendingRequestsProvider),
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
    );
  }
}

class _AcceptedRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(adminAcceptedRequestsProvider);
    final currentLocale = ref.watch(localeProvider);

    return requestsAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocalizationService.tr('failedToLoadRequests', currentLocale).replaceAll('{error}', '$e')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(adminAcceptedRequestsProvider),
              child: Text(LocalizationService.tr('retry', currentLocale)),
            ),
          ],
        ),
      ),
      data: (requests) {
        if (requests.isEmpty) {
          return EmptyState(
            icon: Icons.pending_actions_rounded,
            title: LocalizationService.tr('noAcceptedRequests', currentLocale),
            subtitle: LocalizationService.tr('noAcceptedRequestsDesc', currentLocale),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminAcceptedRequestsProvider),
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
    );
  }
}

class _DonationHistoryTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(adminDonationsHistoryProvider);
    final currentLocale = ref.watch(localeProvider);

    return historyAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocalizationService.tr('failedToLoadRequests', currentLocale).replaceAll('{error}', '$e')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(adminDonationsHistoryProvider),
              child: Text(LocalizationService.tr('retry', currentLocale)),
            ),
          ],
        ),
      ),
      data: (history) {
        if (history.isEmpty) {
          return EmptyState(
            icon: Icons.history_rounded,
            title: LocalizationService.tr('noDonationHistory', currentLocale),
            subtitle: LocalizationService.tr('noDonationHistoryDesc', currentLocale),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminDonationsHistoryProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final donation = history[index];
              return _DonationHistoryCard(donation: donation);
            },
          ),
        );
      },
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
                        ref.invalidate(adminPendingRequestsProvider);
                        ref.invalidate(adminAcceptedRequestsProvider);
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

class _DonationHistoryCard extends ConsumerWidget {
  final Donation donation;

  const _DonationHistoryCard({required this.donation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (donation.bloodGroup != null && donation.bloodGroup!.isNotEmpty)
                            ? LocalizationService.tr('bloodGroupBlood', currentLocale).replaceAll('{bloodGroup}', donation.bloodGroup!)
                            : LocalizationService.tr('donationLabel', currentLocale),
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${donation.units} ${LocalizationService.tr('units', currentLocale)}',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Donor info
            Row(
              children: [
                Expanded(
                  child: _InfoRow(
                    icon: Icons.volunteer_activism_rounded,
                    label: LocalizationService.tr('donorLabel', currentLocale),
                    value: donation.donorName ?? LocalizationService.tr('nA', currentLocale),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _InfoRow(
                    icon: Icons.local_hospital_rounded,
                    label: LocalizationService.tr('hospitalLabel', currentLocale),
                    value: donation.hospitalName ?? LocalizationService.tr('nA', currentLocale),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date
            _InfoRow(
              icon: Icons.calendar_today_rounded,
              label: LocalizationService.tr('dateLabel', currentLocale),
              value: _formatDate(donation.donationDate),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.grey400),
        const SizedBox(width: 4),
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
