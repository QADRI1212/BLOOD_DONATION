import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_textfield.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/blood_bank_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class BloodBanksScreen extends ConsumerStatefulWidget {
  const BloodBanksScreen({super.key});

  @override
  ConsumerState<BloodBanksScreen> createState() => _BloodBanksScreenState();
}

class _BloodBanksScreenState extends ConsumerState<BloodBanksScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  BloodBankQueryParams _getParams() {
    final query = _searchController.text.trim();
    return BloodBankQueryParams(
      query: query.isEmpty ? null : query,
      verified: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloodBanksAsync = ref.watch(bloodBanksProvider(_getParams()));

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('bloodBanks', currentLocale)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTextField(
              controller: _searchController,
              hint: LocalizationService.tr('searchBloodBanks', currentLocale),
              prefixIcon: Icons.search_rounded,
              onChanged: (_) {
                _searchDebounce?.cancel();
                _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                  setState(() {});
                });
              },
            ),
          ),
          Expanded(
            child: bloodBanksAsync.when(
              loading: () => const ListShimmer(),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: AppColors.error.withValues(alpha: 0.7)),
                      const SizedBox(height: 16),
                      Text(LocalizationService.tr('failedToLoadBloodBanks', currentLocale), style: AppTypography.titleMedium),
                      const SizedBox(height: 8),
                      Text('$e', style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: () => ref.invalidate(bloodBanksProvider(_getParams())),
                        icon: const Icon(Icons.refresh, size: 18),
                        label: Text(LocalizationService.tr('retry', currentLocale)),
                      ),
                    ],
                  ),
                ),
              ),
              data: (bloodBanks) {
                if (bloodBanks.isEmpty) {
                  return EmptyState(
                    icon: Icons.bloodtype_rounded,
                    title: LocalizationService.tr('noBloodBanksFound', currentLocale),
                    subtitle: _searchController.text.trim().isNotEmpty
                        ? LocalizationService.tr('noBloodBanksMatch', currentLocale)
                        : LocalizationService.tr('bloodBanksWillAppear', currentLocale),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(bloodBanksProvider(_getParams()));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: bloodBanks.length,
                    itemBuilder: (context, index) {
                      final bank = bloodBanks[index];
                      return _BloodBankCard(bank: bank);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BloodBankCard extends StatelessWidget {
  final dynamic bank;

  const _BloodBankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
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
                  Text(bank.name, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600)),
                  if (bank.address != null) ...[
                    const SizedBox(height: 4),
                    Text(bank.address, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
                  ],
                ],
              ),
            ),
            if (bank.phone != null)
              IconButton(
                icon: Icon(Icons.phone_rounded, color: AppColors.primary),
                onPressed: () async {
                  final uri = Uri.parse('tel:${bank.phone}');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
