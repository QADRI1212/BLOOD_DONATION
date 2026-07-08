import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_textfield.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/hospital_provider.dart';
import '../../blood_banks/providers/blood_bank_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../shared/models/hospital.dart';

class HospitalsScreen extends ConsumerStatefulWidget {
  const HospitalsScreen({super.key});

  @override
  ConsumerState<HospitalsScreen> createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends ConsumerState<HospitalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

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
        title: LocalizationService.tr('hospitals', currentLocale),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey500,
          labelStyle: AppTypography.labelLarge,
          tabs: [
            Tab(
              icon: const Icon(Icons.local_hospital_rounded, size: 20),
              text: LocalizationService.tr('hospitalsTab', currentLocale),
            ),
            Tab(
              icon: const Icon(Icons.bloodtype_rounded, size: 20),
              text: LocalizationService.tr('bloodBanksTab', currentLocale),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _HospitalsTab(),
          _BloodBanksTab(),
        ],
      ),
    );
  }
}

class _HospitalsTab extends ConsumerStatefulWidget {
  const _HospitalsTab();

  @override
  ConsumerState<_HospitalsTab> createState() => _HospitalsTabState();
}

class _HospitalsTabState extends ConsumerState<_HospitalsTab> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  HospitalQueryParams _getParams() {
    final query = _searchController.text.trim();
    return HospitalQueryParams(
      query: query.isEmpty ? null : query,
      verified: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsAsync = ref.watch(hospitalsProvider(_getParams()));
    final currentLocale = ref.watch(localeProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: AppTextField(
            controller: _searchController,
            hint: LocalizationService.tr('searchHospitals', currentLocale),
            prefixIcon: Icons.search_rounded,
            onChanged: (_) {
              _searchDebounce?.cancel();
              _searchDebounce = Timer(const Duration(milliseconds: 300), () {
                setState(() {});
              });
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: hospitalsAsync.when(
            loading: () => const ListShimmer(),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.error.withValues(alpha: 0.7)),
                    const SizedBox(height: 16),
                    Text(LocalizationService.tr('failedToLoadHospitals', currentLocale),
                        style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    Text('$e',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.grey500)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.invalidate(hospitalsProvider(_getParams())),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(LocalizationService.tr('retry', currentLocale)),
                    ),
                  ],
                ),
              ),
            ),
            data: (hospitals) {
              if (hospitals.isEmpty) {
                return EmptyState(
                  icon: Icons.local_hospital_rounded,
                  title: LocalizationService.tr('noHospitalsFound', currentLocale),
                  subtitle: _searchController.text.trim().isNotEmpty
                      ? LocalizationService.tr('noHospitalsMatch', currentLocale)
                      : LocalizationService.tr('hospitalsWillAppear', currentLocale),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(hospitalsProvider(_getParams()));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: hospitals.length,
                  itemBuilder: (context, index) {
                    final hospital = hospitals[index];
                    return HospitalCard(
                      name: hospital.name,
                      address: hospital.address,
                      phone: hospital.phone,
                      hours: hospital.hours,
                      latitude: hospital.latitude,
                      longitude: hospital.longitude,
                      verified: hospital.verified,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BloodBanksTab extends ConsumerStatefulWidget {
  const _BloodBanksTab();

  @override
  ConsumerState<_BloodBanksTab> createState() => _BloodBanksTabState();
}

class _BloodBanksTabState extends ConsumerState<_BloodBanksTab> {
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
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
        const SizedBox(height: 12),
        Expanded(
          child: bloodBanksAsync.when(
            loading: () => const ListShimmer(),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        size: 48, color: AppColors.error.withValues(alpha: 0.7)),
                    const SizedBox(height: 16),
                    Text(LocalizationService.tr('failedToLoadBloodBanks', currentLocale),
                        style: AppTypography.titleMedium),
                    const SizedBox(height: 8),
                    Text('$e',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.grey500)),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.invalidate(bloodBanksProvider(_getParams())),
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
    );
  }
}

class _BloodBankCard extends StatelessWidget {
  final BloodBank bank;

  const _BloodBankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.bloodtype_rounded, color: AppColors.secondary),
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
                              bank.name,
                              style: AppTypography.titleMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (bank.verified)
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Verified',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (bank.address != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          bank.address!,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.grey600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (bank.phone != null || bank.latitude != 0) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (bank.phone != null)
                      OutlinedButton.icon(
                        onPressed: () =>
                            launchUrl(Uri.parse('tel:${bank.phone}')),
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: const Text('Call'),
                      ),
                    if (bank.phone != null &&
                        (bank.latitude != 0 || bank.longitude != 0))
                      const SizedBox(width: 8),
                    if (bank.latitude != 0 || bank.longitude != 0)
                      OutlinedButton.icon(
                        onPressed: () => _openMaps(context),
                        icon: const Icon(Icons.navigation_rounded, size: 18),
                        label: const Text('Navigate'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    try {
      final mapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${bank.latitude},${bank.longitude}',
      );
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        final geoUri =
            Uri.parse('geo:${bank.latitude},${bank.longitude}?q=${bank.latitude},${bank.longitude}');
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        try {
          final webUri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=${bank.latitude},${bank.longitude}',
          );
          await launchUrl(webUri, mode: LaunchMode.platformDefault);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open maps')),
            );
          }
        }
      }
    }
  }
}

class HospitalCard extends StatelessWidget {
  final String name;
  final String? address;
  final String? phone;
  final String? hours;
  final double? latitude;
  final double? longitude;
  final bool verified;

  const HospitalCard({
    super.key,
    required this.name,
    this.address,
    this.phone,
    this.hours,
    this.latitude,
    this.longitude,
    this.verified = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_hospital_rounded,
                      color: AppColors.primary),
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
                              style: AppTypography.titleMedium
                                  .copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          if (verified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successContainer,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Verified',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (address != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          address!,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.grey600),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                      if (hours != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded,
                                size: 14, color: AppColors.grey400),
                            const SizedBox(width: 4),
                            Text(hours!,
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.grey500)),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (phone != null ||
                (latitude != null && longitude != null)) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (phone != null)
                      OutlinedButton.icon(
                        onPressed: () =>
                            launchUrl(Uri.parse('tel:$phone')),
                        icon: const Icon(Icons.phone_rounded, size: 18),
                        label: const Text('Call'),
                      ),
                    if (phone != null &&
                        latitude != null &&
                        longitude != null)
                      const SizedBox(width: 8),
                    if (latitude != null && longitude != null)
                      OutlinedButton.icon(
                        onPressed: () => _openMaps(context),
                        icon: const Icon(Icons.navigation_rounded, size: 18),
                        label: const Text('Navigate'),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openMaps(BuildContext context) async {
    try {
      final mapsUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude',
      );
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } catch (_) {
      try {
        final geoUri =
            Uri.parse('geo:$latitude,$longitude?q=$latitude,$longitude');
        await launchUrl(geoUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        try {
          final webUri = Uri.parse(
            'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
          );
          await launchUrl(webUri, mode: LaunchMode.platformDefault);
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Could not open maps')),
            );
          }
        }
      }
    }
  }
}
