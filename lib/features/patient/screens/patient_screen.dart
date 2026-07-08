import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/patient_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class PatientScreen extends ConsumerWidget {
  const PatientScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.valueOrNull?.id;

    final myRequestsAsync = userId != null ? ref.watch(myRequestsProvider(userId)) : null;

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('patientDashboard', currentLocale),
      ),
      body: authState.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) {
            return const EmptyState(icon: Icons.error_outline, title: 'Please sign in');
          }

          return myRequestsAsync!.when(
            loading: () => const ListShimmer(),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load requests: $e'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.invalidate(myRequestsProvider(userId!)),
                    child: Text(LocalizationService.tr('retry', currentLocale)),
                  ),
                ],
              ),
            ),
            data: (requests) {
              final activeRequests = requests.where((r) => r.status != 'cancelled').toList();

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(myRequestsProvider(userId!));
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _SummaryItem(
                              value: '${requests.length}',
                              label: LocalizationService.tr('total', currentLocale),
                              icon: Icons.assignment_rounded,
                              color: AppColors.primary,
                            ),
                            _SummaryItem(
                              value: '${activeRequests.length}',
                              label: LocalizationService.tr('active', currentLocale),
                              icon: Icons.pending_actions_rounded,
                              color: AppColors.warning,
                            ),
                            _SummaryItem(
                              value: '${requests.where((r) => r.status == 'completed').length}',
                              label: LocalizationService.tr('fulfilled', currentLocale),
                              icon: Icons.check_circle_rounded,
                              color: AppColors.success,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text(LocalizationService.tr('myRequests', currentLocale), style: AppTypography.titleLarge),
                    const SizedBox(height: 12),

                    if (requests.isEmpty)
                      EmptyState(
                        icon: Icons.inbox_rounded,
                        title: LocalizationService.tr('noRequestsYet', currentLocale),
                        subtitle: LocalizationService.tr('createRequestDesc', currentLocale),
                        actionLabel: LocalizationService.tr('createRequest', currentLocale),
                        onAction: () => context.go('/patient/create-request'),
                      )
                    else
                      ...requests.map((request) => _PatientRequestCard(
                            request: request,
                            currentLocale: currentLocale,
                            onTap: () => context.push('/requests/${request.id}'),
                            onCancel: request.status == 'pending'
                                ? () async {
                                    await ref
                                        .read(patientNotifierProvider.notifier)
                                        .cancelRequest(request.id);
                                    ref.invalidate(myRequestsProvider(userId!));
                                  }
                                : null,
                          )),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/patient/create-request'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: Text(
          LocalizationService.tr('newRequest', currentLocale),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700, color: color)),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
      ],
    );
  }
}

class _PatientRequestCard extends StatelessWidget {
  final BloodRequest request;
  final String currentLocale;
  final VoidCallback onTap;
  final VoidCallback? onCancel;

  const _PatientRequestCard({
    required this.request,
    required this.currentLocale,
    required this.onTap,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (request.status) {
      'pending' => AppColors.warning,
      'accepted' => AppColors.info,
      'completed' => AppColors.success,
      'cancelled' => AppColors.grey500,
      _ => AppColors.grey500,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bloodtype_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${request.bloodGroup} Blood',
                      style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.status == 'accepted' && request.donorName != null
                          ? 'Accepted by ${request.donorName}'
                          : '${request.units} unit${request.units > 1 ? "s" : ""} - ${request.status}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
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
                  if (onCancel != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: onCancel,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(LocalizationService.tr('cancel', currentLocale), style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
