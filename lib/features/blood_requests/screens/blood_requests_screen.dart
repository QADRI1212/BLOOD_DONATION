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
import '../providers/blood_request_provider.dart';
import '../providers/paginated_requests_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class BloodRequestsScreen extends ConsumerStatefulWidget {
  const BloodRequestsScreen({super.key});

  @override
  ConsumerState<BloodRequestsScreen> createState() => _BloodRequestsScreenState();
}

class _BloodRequestsScreenState extends ConsumerState<BloodRequestsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedRequestsProvider.notifier).loadFirstPage();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedRequestsProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final paginatedState = ref.watch(paginatedRequestsProvider);

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('bloodRequests', currentLocale),
        actions: [
          if (authState.valueOrNull?.isPatient ?? false)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              onPressed: () => context.push('/patient/create-request'),
            ),
        ],
      ),
      body: authState.when(
        loading: () => const ListShimmer(),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) return const EmptyState(icon: Icons.error_outline, title: 'Please sign in');

          if (paginatedState.isLoading) return const ListShimmer();
          if (paginatedState.error != null && paginatedState.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load: ${paginatedState.error}'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => ref.read(paginatedRequestsProvider.notifier).refresh(),
                    child: Text(LocalizationService.tr('retry', currentLocale)),
                  ),
                ],
              ),
            );
          }

          if (paginatedState.items.isEmpty) {
            return EmptyState(
              icon: Icons.inbox_rounded,
              title: LocalizationService.tr('noBloodRequests', currentLocale),
              subtitle: user.isDonor
                  ? LocalizationService.tr('emergencyRequestsWillAppear', currentLocale)
                  : LocalizationService.tr('createRequestDesc', currentLocale),
              actionLabel: user.isPatient ? LocalizationService.tr('createRequest', currentLocale) : null,
              onAction: () => context.push('/patient/create-request'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(paginatedRequestsProvider.notifier).refresh(),
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
                final request = paginatedState.items[index];
                return _RequestCard(
                  request: request,
                  currentLocale: currentLocale,
                  onTap: () => context.push('/requests/${request.id}'),
                  onAccept: user.isDonor && request.status == 'pending'
                      ? () async {
                          await ref.read(bloodRequestNotifierProvider.notifier)
                              .acceptRequest(request.id, user.id, user.name);
                          ref.invalidate(paginatedRequestsProvider);
                        }
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BloodRequest request;
  final String currentLocale;
  final VoidCallback onTap;
  final VoidCallback? onAccept;

  const _RequestCard({
    required this.request,
    required this.currentLocale,
    required this.onTap,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = request.priority == 'critical';
    final isUrgent = request.priority == 'urgent';
    final priorityColor = isCritical
        ? AppColors.error
        : isUrgent
            ? AppColors.warning
            : AppColors.info;

    final statusColor = switch (request.status) {
      'pending' => AppColors.warning,
      'accepted' => AppColors.info,
      'completed' => AppColors.success,
      'cancelled' => AppColors.grey500,
      _ => AppColors.grey500,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCritical ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isCritical
            ? BorderSide(color: AppColors.error.withValues(alpha: 0.3), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      request.priority.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: priorityColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
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
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.bloodtype_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${request.bloodGroup} Blood Needed',
                          style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${request.units} unit${request.units > 1 ? "s" : ""} required',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (request.patientName != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: AppColors.grey400),
                    const SizedBox(width: 6),
                    Text(request.patientName!, style: AppTypography.bodySmall),
                  ],
                ),
              ],
              if (onAccept != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAccept,
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: Text(LocalizationService.tr('acceptRequest', currentLocale)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
