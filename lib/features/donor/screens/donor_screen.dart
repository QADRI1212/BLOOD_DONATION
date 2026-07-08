import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/donor_eligibility.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_specialty_widgets.dart';
import '../../../shared/widgets/custom_appbar.dart';

class DonorScreen extends ConsumerWidget {
  const DonorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('donorProfile', currentLocale)),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) => user == null
            ? const Center(child: Text('Please sign in'))
            : _buildDonorProfile(context, ref, user),
      ),
    );
  }

  Widget _buildDonorProfile(BuildContext context, WidgetRef ref, UserProfile profile) {
    // Use authProvider data directly (always fresh after updates)
    // instead of donorByIdProvider which caches stale results.
    final currentLocale = ref.watch(localeProvider);

    // Eligibility check
    final eligibility = DonorEligibility.checkEligibility(
      age: profile.age ?? 0,
      weight: profile.weight ?? 0.0,
      lastDonationDate: profile.lastDonationDate,
    );
    final eligibilityMsg = eligibility.isEligible
        ? (profile.lastDonationDate != null
            ? LocalizationService.tr('eligibleToDonate', currentLocale)
            : LocalizationService.tr('eligibleToDonateNow', currentLocale))
        : eligibility.issues.isNotEmpty
            ? eligibility.issues.first
            : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Donor Header
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                ProfileAvatar(
                  initials: profile.initials,
                  radius: 32,
                  isAvailable: profile.isAvailable,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.name, style: AppTypography.titleLarge),
                      const SizedBox(height: 4),
                      Text(
                        profile.isDonor ? LocalizationService.tr('bloodDonor', currentLocale) : LocalizationService.tr('member', currentLocale),
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/donor/edit'),
                  child: Text(LocalizationService.tr('edit', currentLocale)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Eligibility Card
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  eligibility.isEligible ? Icons.check_circle : Icons.info_outline,
                  color: eligibility.isEligible ? AppColors.success : AppColors.warning,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eligibility.isEligible ? LocalizationService.tr('eligibleToDonate', currentLocale) : LocalizationService.tr('notEligible', currentLocale),
                        style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (eligibilityMsg != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          eligibilityMsg,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Blood Group Card
          Text(LocalizationService.tr('bloodInformation', currentLocale), style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    BloodGroupBadge(
                      bloodGroup: profile.bloodGroup ?? 'N/A',
                      size: 56,
                      showLabel: true,
                    ),
                    const Spacer(),
                    StatusChip(
                      status: profile.isAvailable ? LocalizationService.tr('available', currentLocale) : LocalizationService.tr('unavailable', currentLocale),
                      color: profile.isAvailable ? AppColors.success : AppColors.grey500,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _InfoItem(label: LocalizationService.tr('age', currentLocale), value: profile.age?.toString() ?? '--'),
                    _InfoItem(label: LocalizationService.tr('weight', currentLocale), value: profile.weight != null ? '${profile.weight} ${LocalizationService.tr('kg', currentLocale)}' : '--'),
                    _InfoItem(label: LocalizationService.tr('gender', currentLocale), value: profile.gender ?? '--'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Contact Info
          Text(LocalizationService.tr('contact', currentLocale), style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _ContactRow(icon: Icons.email_outlined, value: profile.email),
                if (profile.phone != null) ...[
                  const SizedBox(height: 12),
                  _ContactRow(icon: Icons.phone_outlined, value: profile.phone!),
                ],
                if (profile.city != null) ...[
                  const SizedBox(height: 12),
                  _ContactRow(icon: Icons.location_on_outlined, value: profile.city!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Save button
          AppButton(
            label: LocalizationService.tr('updateAvailability', currentLocale),
            onPressed: () async {
              try {
                await ref.read(authProvider.notifier).updateProfile(
                  profile.copyWith(isAvailable: !profile.isAvailable),
                );
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update: $e'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;

  const _ContactRow({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.grey500),
        const SizedBox(width: 12),
        Text(value, style: AppTypography.bodyMedium),
      ],
    );
  }
}
