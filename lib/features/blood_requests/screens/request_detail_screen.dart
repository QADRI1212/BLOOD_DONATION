import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/hospital.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../donation_history/providers/donation_history_provider.dart';
import '../../donation_history/providers/paginated_history_provider.dart';
import '../../hospitals/providers/hospital_provider.dart';
import '../providers/blood_request_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class RequestDetailScreen extends ConsumerStatefulWidget {
  final String requestId;

  const RequestDetailScreen({super.key, required this.requestId});

  @override
  ConsumerState<RequestDetailScreen> createState() =>
      _RequestDetailScreenState();
}

class _RequestDetailScreenState extends ConsumerState<RequestDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(bloodRequestByIdProvider(widget.requestId));
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
          title: LocalizationService.tr('requestDetails', currentLocale)),
      body: requestAsync.when(
        loading: () => LoadingIndicator(
            message:
                LocalizationService.tr('loadingRequest', currentLocale)),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48,
                    color: AppColors.error.withValues(alpha: 0.7)),
                const SizedBox(height: 16),
                Text(
                    LocalizationService.tr('failedToLoadRequest',
                        currentLocale),
                    style: AppTypography.titleMedium),
                const SizedBox(height: 8),
                Text('$e',
                    style: AppTypography.bodySmall
                        .copyWith(color: AppColors.grey500)),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.invalidate(bloodRequestByIdProvider(widget.requestId)),
                  icon: const Icon(Icons.refresh, size: 18),
                  label:
                      Text(LocalizationService.tr('retry', currentLocale)),
                ),
              ],
            ),
          ),
        ),
        data: (request) {
          if (request == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded,
                      size: 48, color: AppColors.grey400),
                  const SizedBox(height: 16),
                  Text(LocalizationService.tr('requestNotFound',
                      currentLocale)),
                ],
              ),
            );
          }

          final isCritical = request.priority == 'critical';
          final isUrgent = request.priority == 'urgent';
          final priorityColor = isCritical
              ? AppColors.error
              : isUrgent
                  ? AppColors.warning
                  : AppColors.info;

          final statusColor = switch (request.status) {
            'pending' => AppColors.warning,
            'accepted' => AppColors.info,
            'completed' => AppColors.success,
            'cancelled' => AppColors.grey500,
            _ => AppColors.grey500,
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status & Priority
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.priority.toUpperCase(),
                        style: AppTypography.labelLarge.copyWith(
                          color: priorityColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        request.status.toUpperCase(),
                        style: AppTypography.labelLarge.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Blood Group Card
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Hero(
                          tag: 'request_${widget.requestId}_icon',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.bloodtype_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${request.bloodGroup} Blood',
                                style: AppTypography.titleLarge.copyWith(
                                    fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${request.units} unit${request.units > 1 ? "s" : ""} required',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.grey500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Details
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            LocalizationService.tr('requestDetails',
                                currentLocale),
                            style: AppTypography.titleMedium),
                        const SizedBox(height: 16),
                        _DetailRow(
                            label:
                                LocalizationService.tr('patient', currentLocale),
                            value: request.patientName ??
                                LocalizationService.tr(
                                    'anonymous', currentLocale)),
                        _DetailRow(
                            label: LocalizationService.tr(
                                'bloodGroup', currentLocale),
                            value: request.bloodGroup),
                        _DetailRow(
                            label:
                                LocalizationService.tr('units', currentLocale),
                            value: '${request.units}'),
                        _DetailRow(
                            label: LocalizationService.tr(
                                'priority', currentLocale),
                            value: request.priority.toUpperCase()),
                        _DetailRow(
                            label:
                                LocalizationService.tr('status', currentLocale),
                            value: request.status.toUpperCase()),
                        if (request.hospitalName != null)
                          _DetailRow(
                              label: LocalizationService.tr('hospital', currentLocale),
                              value: request.hospitalName!),
                        if (request.address != null)
                          _DetailRow(
                              label: LocalizationService.tr('address', currentLocale),
                              value: request.address!),
                        if (request.donorName != null)
                          _DetailRow(
                              label: LocalizationService.tr(
                                  'acceptedByLabel', currentLocale),
                              value: request.donorName!),
                        if (request.notes != null)
                          _DetailRow(
                              label: LocalizationService.tr(
                                  'notes', currentLocale),
                              value: request.notes!),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                if (request.status == 'pending') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final user =
                            ref.read(authProvider).valueOrNull;
                        if (user != null) {
                          ref
                              .read(bloodRequestNotifierProvider.notifier)
                              .acceptRequest(
                                  widget.requestId, user.id, user.name)
                              .then((_) {
                            if (mounted) {
                              ref.invalidate(
                                  bloodRequestByIdProvider(widget.requestId));
                            }
                          });
                        }
                      },
                      icon: const Icon(Icons.check_circle_outline),
                      label: Text(LocalizationService.tr(
                          'acceptRequestAsDonor', currentLocale)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ] else if (request.status == 'accepted') ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showCompleteDonationDialog(request),
                      icon: const Icon(Icons.task_alt_rounded),
                      label: Text(LocalizationService.tr(
                          'markAsCompleted', currentLocale)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
                if (request.status != 'completed' &&
                    request.status != 'cancelled') ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref
                            .read(bloodRequestNotifierProvider.notifier)
                            .cancelRequest(widget.requestId)
                            .then((_) {
                          if (mounted) {
                            ref.invalidate(
                                bloodRequestByIdProvider(widget.requestId));
                          }
                        });
                      },
                      icon: const Icon(Icons.cancel_outlined),
                      label: Text(LocalizationService.tr(
                          'cancelRequest', currentLocale)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCompleteDonationDialog(BloodRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DonationCompletionSheet(
        request: request,
        requestId: widget.requestId,
        onComplete: (hospital, date, remarks) =>
            _completeDonation(request, hospital, date, remarks),
      ),
    );
  }

  void _completeDonation(
    BloodRequest request,
    Hospital hospital,
    DateTime donationDate,
    String remarks,
  ) {
    ref
        .read(bloodRequestNotifierProvider.notifier)
        .completeRequest(
          widget.requestId,
          hospitalId: hospital.id,
          hospitalName: hospital.name,
          donationDate: donationDate,
          remarks: remarks.isNotEmpty ? remarks : null,
        )
        .then((_) {
      if (mounted) {
        ref.invalidate(bloodRequestByIdProvider(widget.requestId));
        final currentUser = ref.read(authProvider).valueOrNull;
        if (currentUser != null) {
          ref.invalidate(paginatedHistoryProvider(currentUser.id));
          ref.invalidate(donationStatsProvider(currentUser.id));
        }
      }
    });
  }
}

/// Internal widget for the donation completion bottom sheet content.
class _DonationCompletionSheet extends ConsumerStatefulWidget {
  final BloodRequest request;
  final String requestId;
  final void Function(Hospital, DateTime, String) onComplete;

  const _DonationCompletionSheet({
    required this.request,
    required this.requestId,
    required this.onComplete,
  });

  @override
  ConsumerState<_DonationCompletionSheet> createState() =>
      _DonationCompletionSheetState();
}

class _DonationCompletionSheetState
    extends ConsumerState<_DonationCompletionSheet> {
  Hospital? selectedHospital;
  late DateTime donationDate;
  final remarksController = TextEditingController();
  final searchController = TextEditingController();
  bool isLoadingHospitals = true;
  List<Hospital> hospitalList = [];
  List<Hospital> filteredHospitals = [];

  @override
  void initState() {
    super.initState();
    donationDate = DateTime.now();
  }

  @override
  void dispose() {
    remarksController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void _filterHospitals(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredHospitals = hospitalList;
      } else {
        filteredHospitals = hospitalList
            .where(
                (h) => h.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final hospitalsAsync = ref.watch(
        hospitalsProvider(const HospitalQueryParams(verified: true)));

    hospitalsAsync.when(
      data: (data) {
        if (isLoadingHospitals || hospitalList != data) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                isLoadingHospitals = false;
                hospitalList = data;
                filteredHospitals = data;
              });
            }
          });
        }
      },
      loading: () {
        if (!isLoadingHospitals) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => isLoadingHospitals = true);
          });
        }
      },
      error: (_, _) {
        if (isLoadingHospitals) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => isLoadingHospitals = false);
          });
        }
      },
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                LocalizationService.tr('completeDonation', currentLocale),
                style: AppTypography.titleLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(),

            // Scrollable content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                children: [
                  // ---- Donation Date Picker ----
                  Text(
                    LocalizationService.tr('donationDate', currentLocale),
                    style: AppTypography.titleSmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: donationDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        helpText: LocalizationService.tr(
                            'selectDonationDate', currentLocale),
                      );
                      if (picked != null && mounted) {
                        setState(() => donationDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Text(
                            '${donationDate.day}/${donationDate.month}/${donationDate.year}',
                            style: AppTypography.bodyLarge,
                          ),
                          const Spacer(),
                          Icon(Icons.arrow_drop_down,
                              color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---- Hospital Picker ----
                  Text(
                    LocalizationService.tr('selectHospital', currentLocale),
                    style: AppTypography.titleSmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  // Search field
                  TextField(
                    controller: searchController,
                    onChanged: _filterHospitals,
                    decoration: InputDecoration(
                      hintText: LocalizationService.tr(
                          'searchHospitals', currentLocale),
                      prefixIcon: const Icon(Icons.search, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Hospital list
                  if (isLoadingHospitals)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (filteredHospitals.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          LocalizationService.tr(
                              'noHospitalsFound', currentLocale),
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.grey500),
                        ),
                      ),
                    )
                  else
                    ...filteredHospitals.map(
                      (hospital) => ListTile(
                        leading: Icon(
                          selectedHospital?.id == hospital.id
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: selectedHospital?.id == hospital.id
                              ? AppColors.primary
                              : Colors.grey[400],
                          size: 22,
                        ),
                        title: Text(
                          hospital.name,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: hospital.address != null
                            ? Text(
                                hospital.address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySmall
                                    .copyWith(color: AppColors.grey500),
                              )
                            : null,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        onTap: () =>
                            setState(() => selectedHospital = hospital),
                      ),
                    ),
                  const SizedBox(height: 16),

                  // ---- Remarks ----
                  Text(
                    LocalizationService.tr('remarksLabel', currentLocale),
                    style: AppTypography.titleSmall
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: remarksController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: LocalizationService.tr(
                          'optionalRemarks', currentLocale),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),

            // Confirm button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: selectedHospital == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          widget.onComplete(
                            selectedHospital!,
                            donationDate,
                            remarksController.text,
                          );
                        },
                  icon: const Icon(Icons.check_circle_rounded),
                  label: Text(
                      LocalizationService.tr('confirmDonation', currentLocale)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[500],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.grey500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style:
                  AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
