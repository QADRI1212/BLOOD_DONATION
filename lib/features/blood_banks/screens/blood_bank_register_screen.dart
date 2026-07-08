import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_textfield.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../maps/screens/location_picker_screen.dart';
import '../providers/blood_bank_provider.dart';

class BloodBankRegisterScreen extends ConsumerStatefulWidget {
  const BloodBankRegisterScreen({super.key});

  @override
  ConsumerState<BloodBankRegisterScreen> createState() => _BloodBankRegisterScreenState();
}

class _BloodBankRegisterScreenState extends ConsumerState<BloodBankRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _locationAddress;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _openLocationPicker() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initialLatitude: _latitude,
          initialLongitude: _longitude,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _latitude = result['latitude'] as double;
        _longitude = result['longitude'] as double;
        _locationAddress = result['address'] as String?;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final dataSource = ref.read(bloodBankRemoteDataSourceProvider);
      if (_latitude == null || _longitude == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.tr('selectLocation', ref.read(localeProvider))),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.warning,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      await dataSource.insertBloodBank({
        'name': _nameCtrl.text.trim(),
        'address': _addressCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'latitude': _latitude,
        'longitude': _longitude,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.tr('bloodBankRegistered', ref.read(localeProvider))),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/hospital-dashboard');
      }
    } catch (e) {
      if (mounted) {
        String message;
        if (e is PostgrestException && e.code == '42501') {
          message = 'You don\'t have permission to register a blood bank. Please make sure you are logged in with a hospital manager account, or contact an admin.';
        } else {
          message = getUserFriendlyMessage(e, 'Failed to register blood bank. Please try again.');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
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
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('registerBloodBank', currentLocale)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.bloodtype_rounded, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(LocalizationService.tr('registerBloodBank', currentLocale), style: AppTypography.displaySmall),
              const SizedBox(height: 8),
              Text(
                LocalizationService.tr('addBloodBankToNetwork', currentLocale),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 28),

              AppTextField(
                controller: _nameCtrl,
                label: '${LocalizationService.tr('bloodBankName', currentLocale)} *',
                hint: LocalizationService.tr('bloodBankNameHint', currentLocale),
                prefixIcon: Icons.bloodtype_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? LocalizationService.tr('nameRequired', currentLocale) : null,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _addressCtrl,
                label: LocalizationService.tr('address', currentLocale),
                hint: LocalizationService.tr('fullStreetAddress', currentLocale),
                prefixIcon: Icons.location_on_rounded,
                isMultiline: true,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _phoneCtrl,
                label: '${LocalizationService.tr('phoneNumber', currentLocale)} *',
                hint: LocalizationService.tr('phoneNumberHint', currentLocale),
                isPhone: true,
                prefixIcon: Icons.phone_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? LocalizationService.tr('phoneNumberRequired', currentLocale) : null,
              ),
              const SizedBox(height: 16),

              // Location picker button
              InkWell(
                onTap: _openLocationPicker,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _latitude != null ? AppColors.primaryContainer : AppColors.grey50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _latitude != null ? AppColors.primary : AppColors.grey300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.map_rounded,
                        color: _latitude != null ? AppColors.primary : AppColors.grey400,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location *',
                              style: AppTypography.labelMedium.copyWith(
                                color: _latitude != null ? AppColors.primary : AppColors.grey500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (_latitude != null && _longitude != null)
                              Text(
                                _locationAddress ?? '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.grey700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              )
                            else
                              Text(
                                'Tap to open map and select location',
                                style: AppTypography.bodySmall.copyWith(color: AppColors.grey400),
                              ),
                          ],
                        ),
                      ),
                      if (_latitude != null)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: AppColors.grey400),
                          onPressed: () {
                            setState(() {
                              _latitude = null;
                              _longitude = null;
                              _locationAddress = null;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              AppButton(
                label: LocalizationService.tr('registerBloodBank', currentLocale),
                onPressed: _submit,
                isLoading: _isSubmitting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
