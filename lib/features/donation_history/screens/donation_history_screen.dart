import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/donation_history_provider.dart';
import '../providers/paginated_history_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class DonationHistoryScreen extends ConsumerStatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  ConsumerState<DonationHistoryScreen> createState() =>
      _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends ConsumerState<DonationHistoryScreen>
    with WidgetsBindingObserver {
  final ScrollController _scrollController = ScrollController();
  bool _firstBuild = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authProvider).valueOrNull;
      if (user != null) {
        ref.read(paginatedHistoryProvider(user.id).notifier).loadFirstPage();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final user = ref.read(authProvider).valueOrNull;
      if (user != null) {
        ref.read(paginatedHistoryProvider(user.id).notifier).loadNextPage();
      }
    }
  }

  void _refreshData() {
    final user = ref.read(authProvider).valueOrNull;
    if (user != null) {
      ref.invalidate(paginatedHistoryProvider(user.id));
      ref.invalidate(donationStatsProvider(user.id));
      // Reload the first page on the recreated provider after invalidation
      ref.read(paginatedHistoryProvider(user.id).notifier).loadFirstPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull;

    final statsAsync = user != null
        ? ref.watch(donationStatsProvider(user.id))
        : null;
    final paginatedState = user != null
        ? ref.watch(paginatedHistoryProvider(user.id))
        : null;

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('donationHistory', currentLocale)),
      body: authState.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (currentUser) {
          if (currentUser == null) {
            return const EmptyState(
              icon: Icons.error_outline,
              title: 'Please sign in',
            );
          }

          return statsAsync!.when(
            loading: () => const ListShimmer(),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Failed to load stats: $e'),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        ref.invalidate(donationStatsProvider(currentUser.id)),
                    child: Text(LocalizationService.tr('retry', currentLocale)),
                  ),
                ],
              ),
            ),
            data: (stats) {
              if (paginatedState == null) return const ListShimmer();

              if (paginatedState.isLoading) return const ListShimmer();
              if (paginatedState.error != null &&
                  paginatedState.items.isEmpty) {
                return Center(
                  child: Text('Failed to load: ${paginatedState.error}'),
                );
              }

              final totalDonations = stats.totalDonations;
              final totalUnits = stats.totalUnits;
              final lastDate = stats.lastDonationDate;
              final nextEligible = stats.nextEligibleDate;

              int level = 0;
              if (totalDonations >= 10) {
                level = 3;
              } else if (totalDonations >= 5) {
                level = 2;
              } else if (totalDonations >= 1) {
                level = 1;
              }

              final levelLabels = ['New', 'Bronze', 'Silver', 'Gold'];
              final levelIcons = [
                Icons.emoji_events_outlined,
                Icons.emoji_events_rounded,
                Icons.emoji_events_rounded,
                Icons.emoji_events_rounded,
              ];
              final levelColors = [
                AppColors.grey400,
                AppColors.warning,
                AppColors.info,
                AppColors.accent,
              ];

              // Auto-refresh on first build (navigating back)
              if (_firstBuild) {
                _firstBuild = false;
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _refreshData(),
                );
              }

              if (paginatedState.items.isEmpty) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatsCard(
                        totalDonations,
                        totalUnits,
                        levelLabels[level],
                        lastDate,
                        nextEligible,
                        levelColors[level],
                        levelIcons[level],
                        currentLocale,
                      ),
                      const SizedBox(height: 24),
                      _buildAchievements(level, levelIcons, levelColors, currentLocale),
                      const SizedBox(height: 24),Text(LocalizationService.tr('history', currentLocale), style: AppTypography.titleSmall),
                          const SizedBox(height: 12),
                      EmptyState(
                        icon: Icons.history_rounded,
                        title: LocalizationService.tr('noDonationsYet', currentLocale),
                        subtitle: LocalizationService.tr('donationHistoryDesc', currentLocale),
                      ),
                    ],
                  ),
                );
              }

              return CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatsCard(
                            totalDonations,
                            totalUnits,
                            levelLabels[level],
                            lastDate,
                            nextEligible,
                            levelColors[level],
                            levelIcons[level],
                            currentLocale,
                          ),
                          const SizedBox(height: 24),
                          _buildAchievements(level, levelIcons, levelColors, currentLocale),
                          const SizedBox(height: 24),
                          Text(LocalizationService.tr('history', currentLocale), style: AppTypography.titleSmall),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final donation = paginatedState.items[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 3,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 2,
                          ),
                          leading: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.successContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.bloodtype_rounded,
                              color: AppColors.success,
                              size: 16,
                            ),
                          ),
                          title: Text(
                            'At ${donation.hospitalName ?? "a hospital"}',
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _formatDate(donation.donationDate),
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.grey400,
                              fontSize: 11,
                            ),
                          ),
                          trailing: Text(
                            '${donation.units}u',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      );
                    }, childCount: paginatedState.items.length),
                  ),
                  if (paginatedState.hasMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  Widget _buildStatsCard(
    int totalDonations,
    int totalUnits,
    String levelLabel,
    DateTime? lastDate,
    DateTime? nextEligible,
    Color levelColor,
    IconData levelIcon,
    String currentLocale,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text(LocalizationService.tr('donorLevel', currentLocale),
                    style: AppTypography.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(levelIcon, color: Colors.amberAccent, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        levelLabel,
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop, color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '$totalUnits Units',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.white24, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDateInfo('Total Dons', '$totalDonations'),
              _buildDateInfo(
                'Last Donation',
                lastDate != null ? _formatDate(lastDate) : 'None',
              ),
              _buildDateInfo(
                'Next Eligible',
                nextEligible != null ? _formatDate(nextEligible) : 'N/A',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievements(
    int level,
    List<IconData> levelIcons,
    List<Color> levelColors,
    String currentLocale,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(LocalizationService.tr('achievements', currentLocale), style: AppTypography.titleSmall),
        const SizedBox(height: 12),
        SizedBox(
          height: 155,
          child: ListView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            children: [
              _AchievementCard(
                title: LocalizationService.tr('firstBlood', currentLocale),
                description: LocalizationService.tr('makeOneDonation', currentLocale),
                icon: levelIcons[1],
                isUnlocked: level >= 1,
                color: levelColors[1],
              ),
              _AchievementCard(
                title: LocalizationService.tr('superDonor', currentLocale),
                description: LocalizationService.tr('reachFiveDonations', currentLocale),
                icon: levelIcons[2],
                isUnlocked: level >= 2,
                color: levelColors[2],
              ),
              _AchievementCard(
                title: LocalizationService.tr('hero', currentLocale),
                description: LocalizationService.tr('reachTenDonations', currentLocale),
                icon: levelIcons[3],
                isUnlocked: level >= 3,
                color: levelColors[3],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final Color color;

  const _AchievementCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 135,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isUnlocked ? color.withValues(alpha: 0.1) : AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? color.withValues(alpha: 0.3) : AppColors.grey300,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? color.withValues(alpha: 0.2)
                  : AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isUnlocked ? color : AppColors.grey500,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTypography.titleSmall.copyWith(
              color: isUnlocked ? color : AppColors.grey600,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              description,
              style: AppTypography.bodySmall.copyWith(
                color: isUnlocked
                    ? color.withValues(alpha: 0.8)
                    : AppColors.grey500,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
