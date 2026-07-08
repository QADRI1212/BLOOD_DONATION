import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_specialty_widgets.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/profile_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userId = authState.valueOrNull?.id;
    final profileAsync = userId != null ? ref.watch(profileProvider(userId)) : null;

    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('profile', currentLocale),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: authState.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (user) {
          if (user == null) return const Center(child: Text('Please sign in'));

          return profileAsync!.when(
            loading: () => LoadingIndicator(message: LocalizationService.tr('loadingProfile', currentLocale)),
            error: (_, _) => _buildProfile(context, ref, user),
            data: (profileData) => _buildProfile(context, ref, profileData ?? user),
          );
        },
      ),
    );
  }

  Widget _buildProfile(BuildContext context, WidgetRef ref, UserProfile user) {
    final currentLocale = ref.watch(localeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Profile Header
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ProfileAvatar(initials: user.initials, radius: 40, isAvailable: user.isAvailable),
                const SizedBox(height: 16),
                Text(user.name, style: AppTypography.titleLarge),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 8),
                StatusChip(
                  status: user.isDonor ? LocalizationService.tr('donor', currentLocale) : user.role,
                  color: user.isDonor ? AppColors.primary : AppColors.secondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Menu Items
          _ProfileMenuItem(
            icon: Icons.person_outline,
            title: LocalizationService.tr('editProfile', currentLocale),
            subtitle: LocalizationService.tr('updatePersonalInfo', currentLocale),
            onTap: () => context.push('/donor/edit'),
          ),
          _ProfileMenuItem(
            icon: Icons.bloodtype_outlined,
            title: LocalizationService.tr('donationHistory', currentLocale),
            subtitle: LocalizationService.tr('viewDonationRecords', currentLocale),
            onTap: () => context.push('/donation-history'),
          ),
          _ProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: LocalizationService.tr('notifications', currentLocale),
            subtitle: LocalizationService.tr('viewNotifications', currentLocale),
            onTap: () => context.push('/notifications'),
          ),
          _ProfileMenuItem(
            icon: Icons.favorite_outline,
            title: LocalizationService.tr('savedHospitals', currentLocale),
            subtitle: LocalizationService.tr('viewSavedHospitals', currentLocale),
            onTap: () => context.push('/hospitals'),
          ),
          _ProfileMenuItem(
            icon: Icons.favorite_outline,
            title: LocalizationService.tr('healthTips', currentLocale),
            subtitle: LocalizationService.tr('healthTipsDesc', currentLocale),
            onTap: () => context.push('/health-tips'),
          ),
          _ProfileMenuItem(
            icon: Icons.settings_outlined,
            title: LocalizationService.tr('settings', currentLocale),
            subtitle: LocalizationService.tr('settingsDesc', currentLocale),
            onTap: () => context.push('/settings'),
          ),

          if (user.isAdmin) ...[
            const SizedBox(height: 8),
            _ProfileMenuItem(
              icon: Icons.admin_panel_settings_outlined,
              title: LocalizationService.tr('adminPanel', currentLocale),
              subtitle: LocalizationService.tr('managePlatform', currentLocale),
              onTap: () => context.push('/admin'),
              iconColor: AppColors.accent,
            ),
          ],

          const SizedBox(height: 32),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(LocalizationService.tr('signOut', currentLocale)),
                    content: Text(LocalizationService.tr('signOutConfirm', currentLocale)),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(LocalizationService.tr('cancel', currentLocale)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(LocalizationService.tr('signOut', currentLocale)),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/auth/login');
                  }
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: Text(LocalizationService.tr('signOut', currentLocale)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Version
          Text(
            '${LocalizationService.tr('appName', currentLocale)} v1.0.0',
            style: AppTypography.bodySmall.copyWith(color: AppColors.grey400),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.all(4),
        child: ListTile(            leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor ?? AppColors.primary, size: 22),
                  ),
                  title: Text(title, style: AppTypography.titleMedium),
                  subtitle: Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.grey500)),
          trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
          onTap: onTap,
        ),
      ),
    );
  }
}
