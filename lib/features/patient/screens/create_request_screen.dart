import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/blood_request.dart';
import '../../../shared/models/hospital.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_textfield.dart';
import '../../hospitals/providers/hospital_provider.dart';
import '../providers/patient_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() =>
      _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _unitsController = TextEditingController();
  final _addressController = TextEditingController();
  final LocationService _locationService = LocationService();
  final LoggerService _logger = LoggerService();

  String? _selectedBloodGroup;
  String _selectedPriority = 'normal';
  bool _isSubmitting = false;
  bool _locationLoaded = false;
  double _latitude = 0.0;
  double _longitude = 0.0;

  // Hospital fields
  Hospital? _selectedHospital;
  bool _useManualAddress = false;

  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  Future<void> _loadLocation() async {
    _locationLoaded = true;
    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (e) {
      _logger.warning('Could not get location for request: $e');
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _unitsController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final user = ref.read(authProvider).valueOrNull;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.tr(
                'youMustBeSignedIn',
                ref.read(localeProvider),
              ),
            ),
          ),
        );
      }
      setState(() => _isSubmitting = false);
      return;
    }

    final request = BloodRequest(
      id: const Uuid().v4(),
      patientId: user.id,
      patientName: user.name,
      bloodGroup: _selectedBloodGroup ?? '',
      units: int.tryParse(_unitsController.text) ?? 1,
      priority: _selectedPriority,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      latitude: _latitude,
      longitude: _longitude,
      status: 'pending',
      createdAt: DateTime.now(),
      // Hospital info
      hospitalId: _selectedHospital?.id,
      hospitalName: _selectedHospital?.name,
      address: _useManualAddress
          ? (_addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim())
          : (_selectedHospital?.address ??
                (_addressController.text.trim().isNotEmpty
                    ? _addressController.text.trim()
                    : null)),
    );

    try {
      await ref.read(patientNotifierProvider.notifier).createRequest(request);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.tr(
                'requestSubmitted',
                ref.read(localeProvider),
              ),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_locationLoaded) {
      _loadLocation();
    }

    final currentLocale = ref.watch(localeProvider);
    final hospitalsAsync = ref.watch(
      hospitalsProvider(const HospitalQueryParams(verified: true)),
    );

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('createBloodRequest', currentLocale),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocalizationService.tr('emergencyBloodRequest', currentLocale),
                style: AppTypography.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                LocalizationService.tr('fillDetailsToRequest', currentLocale),
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey500,
                ),
              ),
              const SizedBox(height: 8),
              // Location indicator
              Row(
                children: [
                  Icon(
                    _locationLoaded && _latitude != 0.0
                        ? Icons.location_on_rounded
                        : Icons.my_location_rounded,
                    size: 16,
                    color: _locationLoaded && _latitude != 0.0
                        ? AppColors.success
                        : AppColors.grey400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _locationLoaded && _latitude != 0.0
                        ? LocalizationService.tr(
                            'locationDetected',
                            currentLocale,
                          )
                        : LocalizationService.tr(
                            'detectingLocation',
                            currentLocale,
                          ),
                    style: AppTypography.bodySmall.copyWith(
                      color: _locationLoaded && _latitude != 0.0
                          ? AppColors.success
                          : AppColors.grey400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Blood Group
              Text(
                LocalizationService.tr('bloodGroupRequired', currentLocale),
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: LocalizationService.tr(
                    'selectBloodGroup',
                    currentLocale,
                  ),
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                ),
                items: _bloodGroups.map((bg) {
                  return DropdownMenuItem(value: bg, child: Text(bg));
                }).toList(),
                onChanged: (value) =>
                    setState(() => _selectedBloodGroup = value),
                validator: (value) => value == null
                    ? LocalizationService.tr(
                        'pleaseSelectBloodGroup',
                        currentLocale,
                      )
                    : null,
              ),
              const SizedBox(height: 16),

              // Units
              AppTextField(
                controller: _unitsController,
                label: LocalizationService.tr(
                  'unitsRequired',
                  currentLocale,
                ).replaceAll('{units}', '1'),
                hint: LocalizationService.tr('numberOfUnits', currentLocale),
                keyboardType: TextInputType.number,
                prefixIcon: Icons.format_list_numbered_rounded,
              ),
              const SizedBox(height: 16),

              // Priority
              Text(
                LocalizationService.tr('priorityLevel', currentLocale),
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PriorityOption(
                    label: LocalizationService.tr('normal', currentLocale),
                    icon: Icons.check_circle_outline,
                    color: AppColors.info,
                    isSelected: _selectedPriority == 'normal',
                    onTap: () => setState(() => _selectedPriority = 'normal'),
                  ),
                  const SizedBox(width: 8),
                  _PriorityOption(
                    label: LocalizationService.tr('urgent', currentLocale),
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    isSelected: _selectedPriority == 'urgent',
                    onTap: () => setState(() => _selectedPriority = 'urgent'),
                  ),
                  const SizedBox(width: 8),
                  _PriorityOption(
                    label: LocalizationService.tr('critical', currentLocale),
                    icon: Icons.error_rounded,
                    color: AppColors.error,
                    isSelected: _selectedPriority == 'critical',
                    onTap: () => setState(() => _selectedPriority = 'critical'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Hospital Selector ──
              Text(
                LocalizationService.tr('hospital', currentLocale),
                style: AppTypography.titleMedium,
              ),
              const SizedBox(height: 8),
              hospitalsAsync.when(
                data: (hospitals) {
                  if (hospitals.isEmpty && !_useManualAddress) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.warningContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_rounded,
                                size: 18,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No hospitals found. You can enter an address manually.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  }

                  if (!_useManualAddress && _selectedHospital == null) {
                    // Show hospital list as selectable options
                    return Column(
                      children: [
                        SizedBox(
                          height: 160,
                          child: ListView(
                            children: [
                              // Option to enter address manually
                              ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(
                                  Icons.edit_location_rounded,
                                  color: AppColors.grey500,
                                ),
                                title: Text(
                                  'Enter address manually',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.grey600,
                                  ),
                                ),
                                onTap: () =>
                                    setState(() => _useManualAddress = true),
                              ),
                              const Divider(height: 1),
                              ...hospitals.map(
                                (h) => ListTile(
                                  dense: true,
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.local_hospital_rounded,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    h.name,
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: h.address != null
                                      ? Text(
                                          h.address!,
                                          style: AppTypography.bodySmall
                                              .copyWith(
                                                color: AppColors.grey500,
                                              ),
                                        )
                                      : null,
                                  trailing: Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.grey300,
                                  ),
                                  onTap: () =>
                                      setState(() => _selectedHospital = h),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),

              // Selected hospital chip or manual address input
              if (_selectedHospital != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_hospital_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedHospital!.name,
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (_selectedHospital!.address != null)
                              Text(
                                _selectedHospital!.address!,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.grey500,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 18,
                          color: AppColors.grey400,
                        ),
                        onPressed: () => setState(() {
                          _selectedHospital = null;
                          _useManualAddress = false;
                        }),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              if (_useManualAddress || _selectedHospital == null) ...[
                const SizedBox(height: 8),
                AppTextField(
                  controller: _addressController,
                  label: _selectedHospital != null
                      ? LocalizationService.tr('address', currentLocale)
                      : '${LocalizationService.tr('address', currentLocale)} *',
                  hint: 'Enter hospital name and address',
                  prefixIcon: Icons.location_on_rounded,
                  isMultiline: true,
                  maxLines: 2,
                ),
              ],
              const SizedBox(height: 16),

              // Notes
              AppTextField(
                controller: _notesController,
                label: LocalizationService.tr('additionalNotes', currentLocale),
                hint: LocalizationService.tr(
                  'specificRequirements',
                  currentLocale,
                ),
                isMultiline: true,
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 32),

              // Submit
              AppButton(
                label: LocalizationService.tr('submitRequest', currentLocale),
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _PriorityOption({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.1) : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : AppColors.grey200,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? color : AppColors.grey400,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: isSelected ? color : AppColors.grey500,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
