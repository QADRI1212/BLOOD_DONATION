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

class AdminBloodBanksScreen extends ConsumerWidget {
  const AdminBloodBanksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bloodBanksAsync = ref.watch(adminAllBloodBanksProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('manageBloodBanksTitle', currentLocale),
      ),
      body: bloodBanksAsync.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocalizationService.tr('failedToLoad', currentLocale).replaceAll('{error}', '$e')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(adminAllBloodBanksProvider),
                child: Text(LocalizationService.tr('retry', currentLocale)),
              ),
            ],
          ),
        ),
        data: (bloodBanks) {
          if (bloodBanks.isEmpty) {
            return EmptyState(
              icon: Icons.bloodtype_outlined,
              title: LocalizationService.tr('noBloodBanksRegistered', currentLocale),
              subtitle: LocalizationService.tr('bloodBanksWillAppear', currentLocale),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminAllBloodBanksProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bloodBanks.length,
              itemBuilder: (context, index) {
                final b = bloodBanks[index];
                return _BloodBankManageCard(
                  name: b['name'] as String? ?? '',
                  address: b['address'] as String?,
                  phone: b['phone'] as String?,
                  verified: b['verified'] as bool? ?? false,
                  createdAt: b['created_at'] as String?,
                  onDelete: () => _deleteBloodBank(ref, b['id'] as String, b['name'] as String? ?? '', currentLocale),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteBloodBank(WidgetRef ref, String id, String name, String currentLocale) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (ctx) => AlertDialog(
        title: Text(LocalizationService.tr('deleteBloodBank', currentLocale)),
        content: Text(LocalizationService.tr('deleteBloodBankConfirm', currentLocale).replaceAll('{name}', name)),
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
      await ref.read(adminNotifierProvider.notifier).rejectBloodBank(id);
      ref.invalidate(adminAllBloodBanksProvider);
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.tr('bloodBankDeleted', currentLocale)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }
}

class _BloodBankManageCard extends ConsumerWidget {
  final String name;
  final String? address;
  final String? phone;
  final bool verified;
  final String? createdAt;
  final VoidCallback onDelete;

  const _BloodBankManageCard({
    required this.name,
    this.address,
    this.phone,
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
                    Icons.bloodtype_rounded,
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
            if (phone != null || createdAt != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  if (phone != null && phone!.isNotEmpty)
                    _InfoChip(icon: Icons.phone_rounded, text: phone!),
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
