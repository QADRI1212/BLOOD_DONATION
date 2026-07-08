import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class HospitalDashboardScreen extends ConsumerWidget {
  const HospitalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('hospitalDashboard', currentLocale), showBackButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocalizationService.tr('hospitalPanel', currentLocale), style: AppTypography.displaySmall),
            const SizedBox(height: 4),
            Text(
              user?.name ?? LocalizationService.tr('manageYourHospital', currentLocale),
              style: AppTypography.bodyLarge.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    icon: Icons.local_hospital_rounded,
                    label: LocalizationService.tr('hospital', currentLocale),
                    value: LocalizationService.tr('registered', currentLocale),
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(
                    icon: Icons.bloodtype_rounded,
                    label: LocalizationService.tr('bloodBank', currentLocale),
                    value: LocalizationService.tr('manage', currentLocale),
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(LocalizationService.tr('quickActions', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),

            _ActionTile(
              icon: Icons.add_business_rounded,
              title: LocalizationService.tr('registerHospital', currentLocale),
              subtitle: LocalizationService.tr('registerHospitalDesc', currentLocale),
              onTap: () => context.push('/hospital/register'),
            ),
            _ActionTile(
              icon: Icons.bloodtype_rounded,
              title: LocalizationService.tr('registerBloodBank', currentLocale),
              subtitle: LocalizationService.tr('registerBloodBankDesc', currentLocale),
              onTap: () => context.push('/blood-bank/register'),
            ),
            _ActionTile(
              icon: Icons.assignment_rounded,
              title: LocalizationService.tr('bloodRequests', currentLocale),
              subtitle: LocalizationService.tr('viewIncomingRequests', currentLocale),
              onTap: () => context.push('/requests'),
            ),
            _ActionTile(
              icon: Icons.history_rounded,
              title: LocalizationService.tr('donationHistory', currentLocale),
              subtitle: LocalizationService.tr('viewDonationRecords', currentLocale),
              onTap: () => context.push('/donation-history'),
            ),
            _ActionTile(
              icon: Icons.add_circle_rounded,
              title: LocalizationService.tr('createBloodRequest', currentLocale),
              subtitle: LocalizationService.tr('fillDetails', currentLocale),
              onTap: () => context.push('/patient/create-request'),
            ),
            _ActionTile(
              icon: Icons.people_rounded,
              title: LocalizationService.tr('findDonors', currentLocale),
              subtitle: LocalizationService.tr('searchForDonorsDesc', currentLocale),
              onTap: () => context.push('/donors'),
            ),

            const SizedBox(height: 24),
            // Info card
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.info_rounded, color: AppColors.info),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LocalizationService.tr('registrationInfo', currentLocale), style: AppTypography.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          LocalizationService.tr('registrationInfoDesc', currentLocale),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(value, style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.w700)),
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: AppTypography.titleMedium),
        subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
        onTap: onTap,
      ),
    );
  }
}
