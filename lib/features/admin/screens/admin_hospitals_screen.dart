import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class AdminHospitalsScreen extends ConsumerWidget {
  const AdminHospitalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hospitalsAsync = ref.watch(adminAllHospitalsProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('manageHospitalsTitle', currentLocale),
      ),
      body: hospitalsAsync.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocalizationService.tr('failedToLoad', currentLocale).replaceAll('{error}', '$e')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(adminAllHospitalsProvider),
                child: Text(LocalizationService.tr('retry', currentLocale)),
              ),
            ],
          ),
        ),
        data: (hospitals) {
          if (hospitals.isEmpty) {
            return EmptyState(
              icon: Icons.local_hospital_outlined,
              title: LocalizationService.tr('noHospitalsRegistered', currentLocale),
              subtitle: LocalizationService.tr('hospitalsWillAppear', currentLocale),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminAllHospitalsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: hospitals.length,
              itemBuilder: (context, index) {
                final h = hospitals[index];
                return _HospitalManageCard(
                  name: h['name'] as String? ?? '',
                  address: h['address'] as String?,
                  phone: h['phone'] as String?,
                  hours: h['hours'] as String?,
                  verified: h['verified'] as bool? ?? false,
                  createdAt: h['created_at'] as String?,
                  onDelete: () => _deleteHospital(ref, h['id'] as String, h['name'] as String? ?? '', currentLocale),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteHospital(WidgetRef ref, String id, String name, String currentLocale) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (ctx) => AlertDialog(
        title: Text(LocalizationService.tr('deleteHospital', currentLocale)),
        content: Text(LocalizationService.tr('deleteHospitalConfirm', currentLocale).replaceAll('{name}', name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LocalizationService.tr('cancel', currentLocale))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(LocalizationService.tr('delete', currentLocale), style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminNotifierProvider.notifier).rejectHospital(id);
      ref.invalidate(adminAllHospitalsProvider);
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.tr('hospitalDeleted', currentLocale)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

class _HospitalManageCard extends ConsumerWidget {
  final String name;
  final String? address;
  final String? phone;
  final String? hours;
  final bool verified;
  final String? createdAt;
  final VoidCallback onDelete;

  const _HospitalManageCard({
    required this.name,
    this.address,
    this.phone,
    this.hours,
    required this.verified,
    this.createdAt,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: verified
                        ? AppColors.success.withValues(alpha: 0.12)
                        : AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: verified ? AppColors.success : AppColors.warning,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: verified
                                  ? AppColors.success.withValues(alpha: 0.1)
                                  : AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              verified
                                  ? LocalizationService.tr('verified', currentLocale)
                                  : LocalizationService.tr('pending', currentLocale),
                              style: AppTypography.labelSmall.copyWith(
                                color: verified ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (address != null && address!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                address!,
                                style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (phone != null || hours != null || createdAt != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (phone != null && phone!.isNotEmpty)
                    _InfoChip(icon: Icons.phone_rounded, text: phone!),
                  if (hours != null && hours!.isNotEmpty)
                    _InfoChip(icon: Icons.access_time_rounded, text: hours!),
                  if (createdAt != null)
                    _InfoChip(
                      icon: Icons.calendar_today_rounded,
                      text: _formatDate(createdAt!),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: Text(LocalizationService.tr('delete', currentLocale)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.grey400),
        const SizedBox(width: 4),
        Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
      ],
    );
  }
}
