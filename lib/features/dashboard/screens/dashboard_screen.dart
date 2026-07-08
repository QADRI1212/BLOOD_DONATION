import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/donor_eligibility.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../notifications/providers/notification_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with WidgetsBindingObserver {
  DateTime? _lastRefresh;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshDashboard();
    }
  }

  void _refreshDashboard() {
    final user = ref.read(authProvider).valueOrNull;
    if (user != null) {
      ref.invalidate(dashboardProvider(user.id));
      ref.invalidate(recentRequestsProvider(RecentRequestsParams(userId: user.id, forDonor: user.isDonor)));
      ref.invalidate(donationSummaryProvider(user.id));
      _lastRefresh = DateTime.now();
    }
  }

  bool get _shouldRefresh {
    if (_lastRefresh == null) return true;
    return DateTime.now().difference(_lastRefresh!).inSeconds > 30;
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Refresh data whenever the screen is visited (throttled to once per 30s).
    // This ensures stats update after recording a donation or coming back from another tab.
    if (_shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _refreshDashboard());
    }

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: authState.when(
          loading: () => _buildShimmerLoading(),
          error: (error, _) => Center(
            child: Text(LocalizationService.tr('errorGeneric', currentLocale).replaceAll('{error}', '$error')),
          ),
          data: (user) => user == null
              ? Center(child: Text(LocalizationService.tr('pleaseSignIn', currentLocale)))
              : _buildDashboard(context, ref, user, currentLocale),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(width: 56, height: 56, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.white)),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 150, height: 14, color: AppColors.white),
                    SizedBox(height: 8),
                    Container(width: 100, height: 12, color: AppColors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, WidgetRef ref, UserProfile user, String currentLocale) {
    final userId = user.id;
    final dashboardStats = ref.watch(dashboardProvider(userId));
    final recentRequests = ref.watch(recentRequestsProvider(RecentRequestsParams(userId: userId, forDonor: user.isDonor)));
    final donationSummary = ref.watch(donationSummaryProvider(userId));
    final recentNotifications = ref.watch(notificationsProvider(userId));

    // Compute eligibility
    final eligibility = user.age != null && user.weight != null
        ? DonorEligibility.checkEligibility(
            age: user.age!,
            weight: user.weight!,
            lastDonationDate: user.lastDonationDate,
          )
        : null;
    final eligibilityMsg = eligibility != null
        ? DonorEligibility.getEligibilityMessage(
            age: user.age!,
            weight: user.weight!,
            lastDonationDate: user.lastDonationDate,
          )
        : LocalizationService.tr('updateProfileForEligibility', currentLocale);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardProvider(userId));
        ref.invalidate(recentRequestsProvider(RecentRequestsParams(userId: userId, forDonor: user.isDonor)));
        ref.invalidate(donationSummaryProvider(userId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${LocalizationService.tr('hello', currentLocale)}, ${user.name.split(' ').first}',
              style: AppTypography.displaySmall,
            ),
            const SizedBox(height: 4),
            Text(
              user.isDonor ? LocalizationService.tr('readyToSaveLives', currentLocale) : LocalizationService.tr('welcomeToDonorNetwork', currentLocale),
              style: AppTypography.bodyLarge.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 8),
            // Eligibility status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: (eligibility?.isEligible ?? false)
                    ? AppColors.successContainer
                    : AppColors.warningContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    (eligibility?.isEligible ?? false)
                        ? Icons.check_circle_rounded
                        : Icons.info_rounded,
                    size: 16,
                    color: (eligibility?.isEligible ?? false)
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      eligibilityMsg,
                      style: AppTypography.labelSmall.copyWith(
                        color: (eligibility?.isEligible ?? false)
                            ? AppColors.success
                            : AppColors.warning,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats row - user info + dynamic stats
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.bloodtype_rounded,
                    value: user.bloodGroup ?? '--',
                    label: LocalizationService.tr('bloodGroup', currentLocale),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: dashboardStats.when(
                    loading: () => _StatCard(
                      icon: Icons.favorite_rounded,
                      value: '...',
                      label: LocalizationService.tr('donations', currentLocale),
                      color: AppColors.success,
                    ),
                    error: (_, _) => _StatCard(
                      icon: Icons.favorite_rounded,
                      value: '--',
                      label: LocalizationService.tr('donations', currentLocale),
                      color: AppColors.success,
                    ),
                    data: (stats) => _StatCard(
                      icon: Icons.favorite_rounded,
                      value: '${stats.totalDonations}',
                      label: LocalizationService.tr('donations', currentLocale),
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: donationSummary.when(
                    loading: () => _StatCard(
                      icon: Icons.monitor_heart_rounded,
                      value: '...',
                      label: LocalizationService.tr('unitsDonated', currentLocale),
                      color: AppColors.secondary,
                    ),
                    error: (_, _) => _StatCard(
                      icon: Icons.monitor_heart_rounded,
                      value: '--',
                      label: LocalizationService.tr('unitsDonated', currentLocale),
                      color: AppColors.secondary,
                    ),
                    data: (stats) => _StatCard(
                      icon: Icons.monitor_heart_rounded,
                      value: '${stats.totalUnits}',
                      label: LocalizationService.tr('unitsDonated', currentLocale),
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today_rounded,
                    value: user.age?.toString() ?? '--',
                    label: LocalizationService.tr('age', currentLocale),
                    color: AppColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Recent Notifications
            recentNotifications.when(
              data: (notifications) {
                final unread = notifications.where((n) => !n.isRead).take(3).toList();
                if (unread.isEmpty) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(LocalizationService.tr('notifications', currentLocale), style: AppTypography.titleLarge),
                        TextButton(
                          onPressed: () => context.push('/notifications'),
                          child: Text(LocalizationService.tr('viewAll', currentLocale)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...unread.map((n) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        onTap: () => context.push('/notifications'),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: n.type == 'emergency'
                                    ? AppColors.errorContainer
                                    : AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                n.type == 'emergency'
                                    ? Icons.error_rounded
                                    : Icons.notifications_rounded,
                                size: 20,
                                color: n.type == 'emergency'
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 2),
                                  Text(n.body, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500), maxLines: 1, overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),

            // Quick Actions
            Text(LocalizationService.tr('quickActions', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.search_rounded,
                    label: LocalizationService.tr('findDonors', currentLocale),
                    color: AppColors.primary,
                    onTap: () => context.push('/donors'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.local_hospital_rounded,
                    label: LocalizationService.tr('hospitals', currentLocale),
                    color: AppColors.secondary,
                    onTap: () => context.push('/hospitals'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.history_rounded,
                    label: LocalizationService.tr('history', currentLocale),
                    color: AppColors.accent,
                    onTap: () => context.push('/donation-history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Active Requests
            Text(LocalizationService.tr('activeRequests', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            recentRequests.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => AppCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(LocalizationService.tr('failedToLoad', currentLocale).replaceAll('{error}', '$error'),
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
                  ),
                ),
              ),
              data: (requests) {
                if (requests.isEmpty) {
                  return AppCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.inbox_rounded, size: 48, color: AppColors.grey300),
                            const SizedBox(height: 12),
                            Text(LocalizationService.tr('noActiveRequests', currentLocale),
                                style: AppTypography.bodyLarge.copyWith(color: AppColors.grey500)),
                            const SizedBox(height: 4),
                            Text(LocalizationService.tr('emergencyRequestsWillAppear', currentLocale),
                                style: AppTypography.bodySmall.copyWith(color: AppColors.grey400)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  children: requests.map((req) => _RequestCard(
                    request: req,
                    onTap: () => context.push('/requests/${req.id}'),
                  )).toList(),
                );
              },
            ),
            const SizedBox(height: 24),

            // Donation Summary
            donationSummary.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (stats) {
                if (!stats.hasDonated) return const SizedBox.shrink();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(LocalizationService.tr('donationSummary', currentLocale), style: AppTypography.titleLarge),
                    const SizedBox(height: 12),
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text('${stats.totalDonations}',
                                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center),
                                Text(LocalizationService.tr('donations', currentLocale), style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                                    textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text('${stats.totalUnits}',
                                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center),
                                Text(LocalizationService.tr('units', currentLocale), style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                                    textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text(stats.achievementLevel.split(' ').first,
                                    style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
                                    textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                                Text(stats.achievementLevel,
                                    style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                                    textAlign: TextAlign.center, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            ),

            // Donor Availability Toggle
            AppCard(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.successContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.swap_horiz_rounded, color: AppColors.success),
                ),
                title: Text(LocalizationService.tr('donorAvailability', currentLocale),
                    style: AppTypography.titleMedium),
                subtitle: Text(
                  user.isAvailable
                      ? LocalizationService.tr('availableToDonate', currentLocale)
                      : LocalizationService.tr('toggleToReceiveRequests', currentLocale),
                  style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                ),
                trailing: Switch(
                  value: user.isAvailable,
                  onChanged: (value) {
                    ref.read(authProvider.notifier).updateProfile(
                      user.copyWith(isAvailable: value),
                    );
                  },
                  activeTrackColor: AppColors.success,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final BloodRequest request;
  final VoidCallback? onTap;

  const _RequestCard({required this.request, this.onTap});

  @override
  Widget build(BuildContext context) {
    final priorityColor = request.isCritical
        ? AppColors.error
        : request.isUrgent
            ? AppColors.warning
            : AppColors.info;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: onTap,
        child: Row(
          children: [
            Hero(
              tag: 'request_${request.id}_icon',
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: priorityColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  request.isCritical ? Icons.error_rounded : Icons.bloodtype_rounded,
                  color: priorityColor,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${request.bloodGroup} - ${request.units} unit${request.units > 1 ? 's' : ''}',
                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (request.hospitalName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      request.hospitalName!,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.grey600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    '${request.priority.toUpperCase()} · ${_formatDate(request.createdAt)}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                request.priority,
                style: AppTypography.labelSmall.copyWith(
                  color: priorityColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(color: AppColors.grey700),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
