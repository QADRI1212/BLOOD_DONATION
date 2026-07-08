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

class AdminApprovalsScreen extends ConsumerStatefulWidget {
  const AdminApprovalsScreen({super.key});

  @override
  ConsumerState<AdminApprovalsScreen> createState() => _AdminApprovalsScreenState();
}

class _AdminApprovalsScreenState extends ConsumerState<AdminApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('pendingApprovals', currentLocale),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey500,
          tabs: [
            Tab(icon: const Icon(Icons.local_hospital_rounded), text: LocalizationService.tr('hospitalsTab', currentLocale)),
            Tab(icon: const Icon(Icons.bloodtype_rounded), text: LocalizationService.tr('bloodBanksTab', currentLocale)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _PendingHospitalsTab(),
          _PendingBloodBanksTab(),
        ],
      ),
    );
  }
}

class _PendingHospitalsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(adminPendingHospitalsProvider);
    final currentLocale = ref.watch(localeProvider);

    return pendingAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocalizationService.tr('failedToLoad', currentLocale).replaceAll('{error}', '$e')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(adminPendingHospitalsProvider),
              child: Text(LocalizationService.tr('retry', currentLocale)),
            ),
          ],
        ),
      ),
      data: (hospitals) {
        if (hospitals.isEmpty) {
          return EmptyState(
            icon: Icons.check_circle_rounded,
            title: LocalizationService.tr('allCaughtUp', currentLocale),
            subtitle: LocalizationService.tr('noPendingHospitals', currentLocale),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminPendingHospitalsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              final h = hospitals[index];
              return _ApprovalCard(
                name: h['name'] as String? ?? LocalizationService.tr('unknownUser', currentLocale),
                address: h['address'] as String?,
                phone: h['phone'] as String?,
                createdAt: h['created_at'] as String?,
                onApprove: () => _approveHospital(ref, h['id'] as String, currentLocale),
                onReject: () => _rejectHospital(ref, h['id'] as String, h['name'] as String? ?? '', currentLocale),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _approveHospital(WidgetRef ref, String id, String currentLocale) async {
    await ref.read(adminNotifierProvider.notifier).verifyHospital(id);
    ref.invalidate(adminPendingHospitalsProvider);
    if (ref.context.mounted) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text(LocalizationService.tr('hospitalApproved', currentLocale)), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _rejectHospital(WidgetRef ref, String id, String name, String currentLocale) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (ctx) => AlertDialog(
        title: Text(LocalizationService.tr('rejectHospital', currentLocale)),
        content: Text(LocalizationService.tr('rejectHospitalConfirm', currentLocale).replaceAll('{name}', name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LocalizationService.tr('cancel', currentLocale))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(LocalizationService.tr('reject', currentLocale), style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminNotifierProvider.notifier).rejectHospital(id);
      ref.invalidate(adminPendingHospitalsProvider);
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text(LocalizationService.tr('hospitalRejectedRemoved', currentLocale)), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}

class _PendingBloodBanksTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(adminPendingBloodBanksProvider);
    final currentLocale = ref.watch(localeProvider);

    return pendingAsync.when(
      loading: () => const ListShimmer(),
      error: (e, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocalizationService.tr('failedToLoad', currentLocale).replaceAll('{error}', '$e')),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => ref.invalidate(adminPendingBloodBanksProvider),
              child: Text(LocalizationService.tr('retry', currentLocale)),
            ),
          ],
        ),
      ),
      data: (banks) {
        if (banks.isEmpty) {
          return EmptyState(
            icon: Icons.check_circle_rounded,
            title: LocalizationService.tr('allCaughtUp', currentLocale),
            subtitle: LocalizationService.tr('noPendingBloodBanks', currentLocale),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(adminPendingBloodBanksProvider),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: banks.length,
            itemBuilder: (context, index) {
              final b = banks[index];
              return _ApprovalCard(
                name: b['name'] as String? ?? LocalizationService.tr('unknownUser', currentLocale),
                address: b['address'] as String?,
                phone: b['phone'] as String?,
                createdAt: b['created_at'] as String?,
                onApprove: () => _approveBloodBank(ref, b['id'] as String, currentLocale),
                onReject: () => _rejectBloodBank(ref, b['id'] as String, b['name'] as String? ?? '', currentLocale),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _approveBloodBank(WidgetRef ref, String id, String currentLocale) async {
    await ref.read(adminNotifierProvider.notifier).verifyBloodBank(id);
    ref.invalidate(adminPendingBloodBanksProvider);
    if (ref.context.mounted) {
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text(LocalizationService.tr('bloodBankApproved', currentLocale)), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.success),
      );
    }
  }

  Future<void> _rejectBloodBank(WidgetRef ref, String id, String name, String currentLocale) async {
    final confirmed = await showDialog<bool>(
      context: ref.context,
      builder: (ctx) => AlertDialog(
        title: Text(LocalizationService.tr('rejectBloodBank', currentLocale)),
        content: Text(LocalizationService.tr('rejectBloodBankConfirm', currentLocale).replaceAll('{name}', name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(LocalizationService.tr('cancel', currentLocale))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(LocalizationService.tr('reject', currentLocale), style: TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(adminNotifierProvider.notifier).rejectBloodBank(id);
      ref.invalidate(adminPendingBloodBanksProvider);
      if (ref.context.mounted) {
        ScaffoldMessenger.of(ref.context).showSnackBar(
          SnackBar(content: Text(LocalizationService.tr('bloodBankRejectedRemoved', currentLocale)), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}

class _ApprovalCard extends ConsumerWidget {
  final String name;
  final String? address;
  final String? phone;
  final String? createdAt;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _ApprovalCard({
    required this.name,
    this.address,
    this.phone,
    this.createdAt,
    required this.onApprove,
    required this.onReject,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.warningContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.hourglass_empty_rounded, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                      if (address != null) ...[
                        const SizedBox(height: 2),
                        Text(address!, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (phone != null || createdAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (phone != null) ...[
                    Icon(Icons.phone_rounded, size: 14, color: AppColors.grey400),
                    const SizedBox(width: 4),
                    Text(phone!, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
                  ],
                  if (phone != null && createdAt != null) const SizedBox(width: 16),
                  if (createdAt != null) ...[
                    Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.grey400),
                    const SizedBox(width: 4),
                    Text(_formatDate(createdAt!), style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      label: Text(LocalizationService.tr('reject', currentLocale)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: ElevatedButton.icon(
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: Text(LocalizationService.tr('approve', currentLocale)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ),
              ],
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
