import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/providers/theme_provider.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../features/profile/providers/profile_provider.dart';
import '../providers/settings_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emergencyAlertsEnabled = true;
  bool _settingsLoaded = false;

  @override
  Widget build(BuildContext context) {
    final currentTheme = ref.watch(themeModeProvider);
    final isDarkMode = currentTheme == ThemeMode.dark;
    final currentLocale = ref.watch(localeProvider);
    final authUser = ref.watch(authProvider).valueOrNull;
    final userId = authUser?.id;

    // Load settings from provider when userId is available
    if (userId != null && !_settingsLoaded) {
      _loadUserSettings(userId);
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance
          Text('Appearance', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text('Dark Mode', style: AppTypography.titleMedium),
                  subtitle: Text(
                    'Switch between light and dark theme',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  value: isDarkMode,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                    if (userId != null) {
                      ref
                          .read(settingsProvider(userId).notifier)
                          .toggleDarkMode(value);
                    }
                  },
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Language
          Text(LocalizationService.tr('language', currentLocale), style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.language_rounded,
                      color: AppColors.info,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    LocalizationService.tr('language', currentLocale),
                    style: AppTypography.titleMedium,
                  ),
                  subtitle: Text(
                    LocalizationService.tr('languageDesc', currentLocale),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  trailing: DropdownButton<String>(
                    value: currentLocale,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.arrow_drop_down),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'hi', child: Text('हिन्दी')),
                      DropdownMenuItem(value: 'ur', child: Text('اردو')),
                    ],
                    onChanged: (value) {
                      if (value != null && value != currentLocale) {
                        ref.read(localeProvider.notifier).setLocale(value);
                        if (userId != null) {
                          ref
                              .read(settingsProvider(userId).notifier)
                              .toggleLanguage(value);
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications
          Text('Notifications', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Push Notifications',
                    style: AppTypography.titleMedium,
                  ),
                  subtitle: Text(
                    'Receive push notifications',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                    if (userId != null) {
                      ref
                          .read(settingsProvider(userId).notifier)
                          .toggleNotifications(value);
                    }
                  },
                  activeTrackColor: AppColors.primary,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    'Emergency Alerts',
                    style: AppTypography.titleMedium,
                  ),
                  subtitle: Text(
                    'Receive emergency blood request alerts',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  value: _emergencyAlertsEnabled,
                  onChanged: (value) =>
                      setState(() => _emergencyAlertsEnabled = value),
                  activeTrackColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account
          Text('Account', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: AppColors.info,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Privacy Policy',
                    style: AppTypography.titleMedium,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
                  ),
                  onTap: () => _showInfoDialog(
                    context,
                    'Privacy Policy',
                    'Your privacy is important to us. We collect and use your personal information solely for the purpose of connecting blood donors with recipients. Your data is stored securely and is never shared with third parties without your explicit consent.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: AppColors.info,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Terms of Service',
                    style: AppTypography.titleMedium,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
                  ),
                  onTap: () => _showInfoDialog(
                    context,
                    'Terms of Service',
                    'By using Blood Donor Network, you agree to use the platform responsibly. Donors must provide accurate health information. All interactions between donors and recipients are voluntary. The platform is not responsible for any medical outcomes resulting from donations.',
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.infoContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 22,
                    ),
                  ),
                  title: Text('About', style: AppTypography.titleMedium),
                  subtitle: Text(
                    'Version 1.0.0',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
                  ),
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Blood Donor Network',
                    applicationVersion: '1.0.0',
                    applicationLegalese:
                        'Connecting blood donors with those in need.',
                    children: [
                      const SizedBox(height: 16),
                      const Text(
                        'Blood Donor Network is a platform that connects blood donors with patients and hospitals in need of blood donations.',
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.flag_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    'Report an Issue',
                    style: AppTypography.titleMedium,
                  ),
                  subtitle: Text(
                    'Submit feedback or report a problem',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.grey400,
                  ),
                  onTap: () => _showReportDialog(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Danger Zone
          Text('Danger Zone', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(4),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete_forever_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              title: Text(
                'Delete Account',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              subtitle: Text(
                'Permanently delete your account and data',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey400,
              ),
              onTap: () => _showDeleteAccountDialog(context),
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          Text('Sign Out', style: AppTypography.titleLarge),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(4),
            child: ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 22,
                ),
              ),
              title: Text(
                'Sign Out',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
              subtitle: Text(
                'Sign out of your account',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.grey400,
              ),
              onTap: () => _showLogoutDialog(context),
            ),
          ),
          const SizedBox(height: 64),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                final currentUser = ref.read(authProvider).valueOrNull;
                if (currentUser != null) {
                  final dataSource = ref.read(profileRemoteDataSourceProvider);
                  await dataSource.deleteAccount(currentUser.id);
                }
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) {
                  context.go('/auth/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go('/auth/login');
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String body) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  final List<String> _reportReasons = [
    'Inappropriate Content',
    'Spam or Harassment',
    'Bug or Technical Issue',
    'Suspicious User',
    'Other',
  ];

  void _showReportDialog() {
    String selectedReason = _reportReasons.first;
    final detailsController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Report an Issue'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Help us improve the platform by reporting issues you encounter.',
                      style: TextStyle(fontSize: 14, color: AppColors.grey500),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Issue Type',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedReason,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: _reportReasons
                          .map(
                            (r) => DropdownMenuItem(value: r, child: Text(r)),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setDialogState(() => selectedReason = v);
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Details (optional)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: detailsController,
                      decoration: const InputDecoration(
                        hintText: 'Describe the issue...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setDialogState(() => isSubmitting = true);
                          try {
                            final currentUser = ref
                                .read(authProvider)
                                .valueOrNull;
                            if (currentUser == null) {
                              throw Exception(
                                'You must be logged in to submit a report.',
                              );
                            }

                            final supabase = SupabaseClientService().client;
                            await supabase.from('reports').insert({
                              'reporter_id': currentUser.id,
                              'reason': detailsController.text.trim().isNotEmpty
                                  ? '$selectedReason - ${detailsController.text.trim()}'
                                  : selectedReason,
                            });
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Report submitted successfully! Thank you for your feedback.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          } catch (e) {
                            setDialogState(() => isSubmitting = false);
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to submit: $e'),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Submit Report'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _loadUserSettings(String userId) {
    _settingsLoaded = true;
    final settingsState = ref.read(settingsProvider(userId));
    final settings = settingsState.valueOrNull;
    if (settings != null) {
      setState(() {
        _notificationsEnabled = settings.notificationsEnabled;
        _emergencyAlertsEnabled = settings.emergencyAlertsEnabled;
      });
      // Sync locale from server-side preferences
      final savedLocale = ref.read(localeProvider);
      if (settings.language != savedLocale &&
          LocalizationService.supportedLocales.contains(settings.language)) {
        ref.read(localeProvider.notifier).setLocale(settings.language);
      }

    }
  }
}
