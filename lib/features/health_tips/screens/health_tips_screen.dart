import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/widgets/app_card.dart';

class HealthTipsScreen extends ConsumerWidget {
  const HealthTipsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('healthTips', currentLocale)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Eligibility Guidelines
            Text(LocalizationService.tr('donationEligibility', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TipRow(icon: Icons.check_circle_rounded, text: LocalizationService.tr('eligibilityAge', currentLocale)),
                  _TipRow(icon: Icons.check_circle_rounded, text: LocalizationService.tr('eligibilityWeight', currentLocale)),
                  _TipRow(icon: Icons.check_circle_rounded, text: LocalizationService.tr('eligibilityHealth', currentLocale)),
                  _TipRow(icon: Icons.check_circle_rounded, text: LocalizationService.tr('eligibilityHemoglobin', currentLocale)),
                  _TipRow(icon: Icons.check_circle_rounded, text: LocalizationService.tr('eligibilityLastDonation', currentLocale)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Before Donation
            Text(LocalizationService.tr('beforeYouDonate', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TipRow(icon: Icons.restaurant_rounded, text: LocalizationService.tr('beforeEatHealthy', currentLocale)),
                  _TipRow(icon: Icons.water_drop_rounded, text: LocalizationService.tr('beforeDrinkWater', currentLocale)),
                  _TipRow(icon: Icons.bedtime_rounded, text: LocalizationService.tr('beforeSleep', currentLocale)),
                  _TipRow(icon: Icons.fastfood_rounded, text: LocalizationService.tr('beforeNoAlcohol', currentLocale)),
                  _TipRow(icon: Icons.smoke_free_rounded, text: LocalizationService.tr('beforeNoSmoking', currentLocale)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // During Donation
            Text(LocalizationService.tr('duringDonation', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TipRow(icon: Icons.spa_rounded, text: LocalizationService.tr('duringRelax', currentLocale)),
                  _TipRow(icon: Icons.timer_rounded, text: LocalizationService.tr('duringTime', currentLocale)),
                  _TipRow(icon: Icons.mic_rounded, text: LocalizationService.tr('duringNotifyStaff', currentLocale)),
                  _TipRow(icon: Icons.music_note_rounded, text: LocalizationService.tr('duringDistract', currentLocale)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // After Donation
            Text(LocalizationService.tr('afterYouDonate', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TipRow(icon: Icons.restaurant_rounded, text: LocalizationService.tr('afterSnack', currentLocale)),
                  _TipRow(icon: Icons.event_seat_rounded, text: LocalizationService.tr('afterRest', currentLocale)),
                  _TipRow(icon: Icons.fitness_center_rounded, text: LocalizationService.tr('afterNoExercise', currentLocale)),
                  _TipRow(icon: Icons.liquor_rounded, text: LocalizationService.tr('afterNoAlcohol', currentLocale)),
                  _TipRow(icon: Icons.air_rounded, text: LocalizationService.tr('afterDizzy', currentLocale)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Health Benefits
            Text(LocalizationService.tr('healthBenefits', currentLocale), style: AppTypography.titleLarge),
            const SizedBox(height: 12),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TipRow(icon: Icons.favorite_rounded, text: LocalizationService.tr('benefitIron', currentLocale)),
                  _TipRow(icon: Icons.monitor_heart_rounded, text: LocalizationService.tr('benefitHealthCheck', currentLocale)),
                  _TipRow(icon: Icons.autorenew_rounded, text: LocalizationService.tr('benefitNewCells', currentLocale)),
                  _TipRow(icon: Icons.volunteer_activism_rounded, text: LocalizationService.tr('benefitCalories', currentLocale)),
                  _TipRow(icon: Icons.emoji_emotions_rounded, text: LocalizationService.tr('benefitSatisfaction', currentLocale)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Important Medical Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_rounded, color: AppColors.info, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(LocalizationService.tr('medicalNote', currentLocale), style: AppTypography.titleMedium.copyWith(color: AppColors.info)),
                        const SizedBox(height: 4),
                        Text(
                          LocalizationService.tr('medicalNoteBody', currentLocale),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: AppTypography.bodyMedium),
          ),
        ],
      ),
    );
  }
}
