import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_service.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/admin_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

final adminAnnouncementsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final api = ApiService();
  final data = await api.query(
    'announcements',
    orderBy: 'created_at',
    ascending: false,
  );
  return data;
});

class AdminAnnouncementsScreen extends ConsumerStatefulWidget {
  const AdminAnnouncementsScreen({super.key});

  @override
  ConsumerState<AdminAnnouncementsScreen> createState() => _AdminAnnouncementsScreenState();
}

class _AdminAnnouncementsScreenState extends ConsumerState<AdminAnnouncementsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isPublishing = false;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _publishAnnouncement(String currentLocale) async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationService.tr('enterTitleBody', currentLocale)),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isPublishing = true);

    try {
      await ref.read(adminNotifierProvider.notifier).createAnnouncement(title, body);

      if (mounted) {
        ref.invalidate(adminAnnouncementsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.tr('announcementPublished', currentLocale)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
        _titleController.clear();
        _bodyController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.tr('failedToPublish', currentLocale).replaceAll('{error}', '$e')),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPublishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final announcementsAsync = ref.watch(adminAnnouncementsProvider);
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('announcements', currentLocale),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateDialog(currentLocale),
          ),
        ],
      ),
      body: announcementsAsync.when(
        loading: () => const ListShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocalizationService.tr('failedToLoad', currentLocale).replaceAll('{error}', '$e')),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => ref.invalidate(adminAnnouncementsProvider),
                child: Text(LocalizationService.tr('retry', currentLocale)),
              ),
            ],
          ),
        ),
        data: (announcements) {
          if (announcements.isEmpty) {
            return EmptyState(
              icon: Icons.campaign_outlined,
              title: LocalizationService.tr('noAnnouncements', currentLocale),
              subtitle: LocalizationService.tr('announcementsWillAppear', currentLocale),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(adminAnnouncementsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                final a = announcements[index];
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                a['title'] as String? ?? '',
                                style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          a['description'] as String? ?? '',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.grey600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatDate(a['created_at'] as String?),
                          style: AppTypography.bodySmall.copyWith(color: AppColors.grey400),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showCreateDialog(String currentLocale) {
    _titleController.clear();
    _bodyController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocalizationService.tr('createAnnouncement', currentLocale), style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: LocalizationService.tr('title', currentLocale),
                  hintText: LocalizationService.tr('enterTitle', currentLocale),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bodyController,
                decoration: InputDecoration(
                  labelText: LocalizationService.tr('body', currentLocale),
                  hintText: LocalizationService.tr('enterBody', currentLocale),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: LocalizationService.tr('publishAnnouncement', currentLocale),
                onPressed: () => _publishAnnouncement(currentLocale),
                isLoading: _isPublishing,
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    final dt = DateTime.tryParse(dateStr);
    if (dt == null) return '';
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}
