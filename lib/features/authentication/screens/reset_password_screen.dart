import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/services/localization_service.dart';
import '../../../shared/widgets/custom_appbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_textfield.dart';

/// Screen shown after the user clicks the password recovery link in their
/// email. Lets them enter and confirm a new password.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).updatePassword(
            _passwordController.text,
          );
      // Clear the recovery mode flag so the router stops redirecting here
      AuthStateProvider().setRecoveryMode(false);
      if (mounted) {
        setState(() => _isSuccess = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(getUserFriendlyMessage(e)),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('resetPassword', currentLocale),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _isSuccess ? _buildSuccessView(currentLocale) : _buildForm(currentLocale),
        ),
      ),
    );
  }

  Widget _buildForm(String currentLocale) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.infoContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 48,
                color: AppColors.info,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Create New Password',
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your new password below.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 32),
          AppTextField(
            controller: _passwordController,
            label: 'New Password',
            hint: 'Enter new password',
            isPassword: true,
            prefixIcon: Icons.lock_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Password is required';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          AppTextField(
            controller: _confirmController,
            label: LocalizationService.tr('confirmPassword', currentLocale),
            hint: 'Re-enter new password',
            isPassword: true,
            prefixIcon: Icons.lock_outlined,
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          AppButton(
            label: 'Update Password',
            onPressed: _updatePassword,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(String currentLocale) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 80),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.successContainer,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 64,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),          Text(
            'Password Updated',
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: 16),
          Text(
            'Your password has been updated successfully. Please sign in with your new password.',
          style: AppTypography.bodyLarge.copyWith(color: AppColors.grey500),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        AppButton(
          label: LocalizationService.tr('backToSignIn', currentLocale),
          onPressed: () => context.go('/auth/login'),
        ),
      ],
    );
  }
}
