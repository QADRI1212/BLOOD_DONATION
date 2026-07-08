import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_textfield.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../core/services/location_service.dart';

class DonorEditScreen extends ConsumerStatefulWidget {
  const DonorEditScreen({super.key});

  @override
  ConsumerState<DonorEditScreen> createState() => _DonorEditScreenState();
}

class _DonorEditScreenState extends ConsumerState<DonorEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  final LocationService _locationService = LocationService();
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;

  String? _selectedBloodGroup;
  String? _selectedGender;
  bool _isAvailable = false;
  bool _isSaving = false;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['male', 'female', 'other'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).valueOrNull;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone ?? '';
      _cityController.text = user.city ?? '';
      _weightController.text = user.weight?.toString() ?? '';
      _ageController.text = user.age?.toString() ?? '';
      _selectedBloodGroup = user.bloodGroup;
      _selectedGender = user.gender;
      _isAvailable = user.isAvailable;
      _latitude = user.latitude;
      _longitude = user.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _updateLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      final position = await _locationService.getCurrentPosition();
      final address = await _locationService.getAddressFromLatLng(position.latitude, position.longitude);
      
      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          if (address != 'Unknown Location') {
            _cityController.text = address;
          }
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationService.tr('locationUpdated', ref.read(localeProvider))),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGettingLocation = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final user = ref.read(authProvider).valueOrNull;
    if (user == null) return;

    try {
      await ref.read(authProvider.notifier).updateProfile(
        user.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
          weight: double.tryParse(_weightController.text),
          age: int.tryParse(_ageController.text),
          bloodGroup: _selectedBloodGroup,
          gender: _selectedGender,
          isAvailable: _isAvailable,
          latitude: _latitude,
          longitude: _longitude,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
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
            content: Text('Failed to update: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('editProfile', currentLocale), showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocalizationService.tr('personalInformation', currentLocale), style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                label: LocalizationService.tr('fullName', currentLocale),
                hint: LocalizationService.tr('enterFullName', currentLocale),
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                label: LocalizationService.tr('phoneNumber', currentLocale),
                hint: LocalizationService.tr('enterPhoneNumber', currentLocale),
                isPhone: true,
                prefixIcon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _cityController,
                      label: LocalizationService.tr('cityAddress', currentLocale),
                      hint: LocalizationService.tr('enterYourCity', currentLocale),
                      prefixIcon: Icons.location_city_outlined,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isGettingLocation ? null : _updateLocation,
                    icon: _isGettingLocation 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.my_location_rounded),
                    tooltip: 'Get current location',
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
              if (_latitude != null && _longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, left: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                      const SizedBox(width: 4),
                      Text('Location coordinates saved', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              Text(LocalizationService.tr('medicalInformation', currentLocale), style: AppTypography.titleLarge),
              const SizedBox(height: 16),
              // Blood Group
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedBloodGroup,
                decoration: InputDecoration(
                  labelText: LocalizationService.tr('bloodGroup', currentLocale),
                  prefixIcon: Icon(Icons.bloodtype_outlined),
                ),
                items: _bloodGroups.map((bg) {
                  return DropdownMenuItem(value: bg, child: Text(bg));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBloodGroup = value),
              ),
              const SizedBox(height: 16),
              // Gender
              DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: _selectedGender,
                decoration: InputDecoration(
                  labelText: LocalizationService.tr('gender', currentLocale),
                  prefixIcon: Icon(Icons.people_outline),
                ),
                items: _genders.map((g) {
                  return DropdownMenuItem(value: g, child: Text(g));
                }).toList(),
                onChanged: (value) => setState(() => _selectedGender = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _ageController,
                      label: LocalizationService.tr('age', currentLocale),
                      hint: LocalizationService.tr('age', currentLocale),
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.calendar_today_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppTextField(
                      controller: _weightController,
                      label: '${LocalizationService.tr('weight', currentLocale)} (${LocalizationService.tr('kg', currentLocale)})',
                      hint: LocalizationService.tr('weight', currentLocale),
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.monitor_weight_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              AppButton(
                label: LocalizationService.tr('saveChanges', currentLocale),
                onPressed: _save,
                isLoading: _isSaving,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
