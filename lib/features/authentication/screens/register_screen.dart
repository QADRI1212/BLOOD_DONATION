import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_textfield.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'donor';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _navigateToRoleScreen(BuildContext context, String role) {
    switch (role) {
      case 'patient':
        context.go('/patient');
        break;
      case 'hospital':
        context.go('/hospitals');
        break;
      case 'admin':
        context.go('/admin');
        break;
      case 'donor':
      default:
        context.go('/dashboard');
        break;
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      final locale = ref.read(localeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizationService.tr('passwordsDoNotMatch', locale)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    await ref.read(authProvider.notifier).signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: _selectedRole,
    );

    // After signUp completes, check the auth state to decide where to go.
    // If signUp returned data(null), it means email confirmation is required.
    if (mounted) {
      final authState = ref.read(authProvider);
      authState.whenOrNull(
        data: (user) {
          if (user == null) {
            final locale = ref.read(localeProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  LocalizationService.tr('verificationEmailSent', locale),
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
              ),
            );
            context.go('/auth/login/verify-email',
                extra: _emailController.text.trim());
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);

    ref.listen<AsyncValue<UserProfile?>>(authProvider, (prev, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            // Email was already confirmed (auto-confirm enabled)
            final locale = ref.read(localeProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(LocalizationService.tr('accountCreated', locale)),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.success,
              ),
            );
            _navigateToRoleScreen(context, user.role);
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(getUserFriendlyMessage(error)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: CustomAppBar(title: LocalizationService.tr('createAccount', currentLocale)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text(
                  LocalizationService.tr('joinNetwork', currentLocale),
                  style: AppTypography.displaySmall,
                ),
                const SizedBox(height: 8),
                Text(
                  LocalizationService.tr('joinNetworkDesc', currentLocale),
                  style: AppTypography.bodyLarge.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 28),
                // Role Selection
                Text(
                  LocalizationService.tr('iamA', currentLocale),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRoleSelector(),
                const SizedBox(height: 28),
                // Name
                AppTextField(
                  controller: _nameController,
                  label: LocalizationService.tr('fullName', currentLocale),
                  hint: LocalizationService.tr('enterFullName', currentLocale),
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: 16),
                // Email
                AppTextField(
                  controller: _emailController,
                  label: LocalizationService.tr('email', currentLocale),
                  hint: LocalizationService.tr('enterEmail', currentLocale),
                  isEmail: true,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                // Phone
                AppTextField(
                  controller: _phoneController,
                  label: LocalizationService.tr('phoneNumber', currentLocale),
                  hint: LocalizationService.tr('enterPhoneNumber', currentLocale),
                  isPhone: true,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 16),
                // Password
                AppTextField(
                  controller: _passwordController,
                  label: LocalizationService.tr('password', currentLocale),
                  hint: LocalizationService.tr('enterPassword', currentLocale),
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                ),
                const SizedBox(height: 16),
                // Confirm Password
                AppTextField(
                  controller: _confirmPasswordController,
                  label: LocalizationService.tr('confirmPassword', currentLocale),
                  hint: LocalizationService.tr('reenterPassword', currentLocale),
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                ),
                const SizedBox(height: 32),
                // Register button
                AppButton(
                  label: LocalizationService.tr('createAccount', currentLocale),
                  onPressed: _register,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 24),
                // Login link
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        LocalizationService.tr('alreadyHaveAccount', currentLocale),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(LocalizationService.tr('signIn', currentLocale)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    final locale = ref.watch(localeProvider);
    return Row(
      children: [
        Expanded(child: _buildRoleCard('donor', Icons.bloodtype_rounded, LocalizationService.tr('donor', locale), LocalizationService.tr('donateBloodDesc', locale))),
        const SizedBox(width: 12),
        Expanded(child: _buildRoleCard('patient', Icons.person_rounded, LocalizationService.tr('patient', locale), LocalizationService.tr('requestBloodDesc', locale))),
      ],
    );
  }

  Widget _buildRoleCard(String role, IconData icon, String title, String subtitle) {
    final isSelected = _selectedRole == role;

    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.grey200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.grey400,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.grey700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTypography.caption.copyWith(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.grey400,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
