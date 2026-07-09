import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(adminStatsProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('adminDashboard', currentLocale),
        showBackButton: false,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminStatsProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocalizationService.tr('adminPanelTitle', currentLocale), style: AppTypography.displaySmall),
              const SizedBox(height: 4),
              Text(LocalizationService.tr('manageNetwork', currentLocale), style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500)),
              const SizedBox(height: 16),

              // Stats Grid
              statsAsync.when(
                loading: () => const Row(
                  children: [
                    Expanded(child: ListShimmer()),
                    SizedBox(width: 12),
                    Expanded(child: ListShimmer()),
                  ],
                ),
                error: (e, _) => Center(
                  child: Column(
                    children: [
                      Text(LocalizationService.tr('failedToLoadStats', currentLocale).replaceAll('{error}', '$e')),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(adminStatsProvider),
                        child: Text(LocalizationService.tr('retry', currentLocale)),
                      ),
                    ],
                  ),
                ),
                data: (stats) => Column(
                  children: [
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _AdminStatCard(
                              label: LocalizationService.tr('totalUsers', currentLocale),
                              value: '${stats.totalUsers}',
                              icon: Icons.people_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AdminStatCard(
                              label: LocalizationService.tr('activeDonors', currentLocale),
                              value: '${stats.activeDonors}',
                              icon: Icons.bloodtype_rounded,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _AdminStatCard(
                              label: LocalizationService.tr('totalRequests', currentLocale),
                              value: '${stats.totalRequests}',
                              icon: Icons.assignment_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _AdminStatCard(
                              label: LocalizationService.tr('totalHospitals', currentLocale),
                              value: '${stats.totalHospitals}',
                              icon: Icons.local_hospital_rounded,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Admin Actions
              Text(LocalizationService.tr('quickActions', currentLocale), style: AppTypography.titleLarge),
              const SizedBox(height: 8),
              _AdminActionTile(
                icon: Icons.people_rounded,
                title: LocalizationService.tr('manageUsers', currentLocale),
                subtitle: LocalizationService.tr('manageUsersDesc', currentLocale),
                onTap: () => context.go('/admin/users'),
              ),
              _AdminActionTile(
                icon: Icons.assignment_rounded,
                title: LocalizationService.tr('manageRequests', currentLocale),
                subtitle: LocalizationService.tr('manageRequestsDesc', currentLocale),
                onTap: () => context.go('/admin/requests'),
              ),
              _AdminActionTile(
                icon: Icons.campaign_rounded,
                title: LocalizationService.tr('announcements', currentLocale),
                subtitle: LocalizationService.tr('announcementsDesc', currentLocale),
                onTap: () => context.go('/admin/announcements'),
              ),
              _AdminActionTile(
                icon: Icons.checklist_rounded,
                title: LocalizationService.tr('approvals', currentLocale),
                subtitle: LocalizationService.tr('approvalsDesc', currentLocale),
                onTap: () => context.go('/admin/approvals'),
              ),
              _AdminActionTile(
                icon: Icons.flag_rounded,
                title: LocalizationService.tr('reports', currentLocale),
                subtitle: LocalizationService.tr('reportsDesc', currentLocale),
                onTap: () => context.go('/admin/reports'),
              ),
              _AdminActionTile(
                icon: Icons.local_hospital_rounded,
                title: LocalizationService.tr('manageHospitals', currentLocale),
                subtitle: LocalizationService.tr('manageHospitalsDesc', currentLocale),
                onTap: () => context.go('/admin/hospitals'),
              ),
              _AdminActionTile(
                icon: Icons.bloodtype_rounded,
                title: LocalizationService.tr('manageBloodBanks', currentLocale),
                subtitle: LocalizationService.tr('manageBloodBanksDesc', currentLocale),
                onTap: () => context.go('/admin/blood-banks'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _AdminStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.grey500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _AdminActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AdminActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400, size: 20),
          onTap: onTap,
        ),
      ),
    );
  }
}
