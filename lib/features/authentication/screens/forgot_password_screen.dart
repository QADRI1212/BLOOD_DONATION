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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).resetPassword(
        _emailController.text.trim(),
      );
      setState(() => _isSuccess = true);
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
      appBar: CustomAppBar(title: LocalizationService.tr('resetPassword', currentLocale)),
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
            LocalizationService.tr('forgotPasswordTitle', currentLocale),
            style: AppTypography.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email and we\'ll send you a reset link.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: 32),
          AppTextField(
            controller: _emailController,
            label: LocalizationService.tr('email', currentLocale),
            hint: LocalizationService.tr('enterRegisteredEmail', currentLocale),
            isEmail: true,
            prefixIcon: Icons.email_outlined,
          ),
          const SizedBox(height: 32),
          AppButton(
            label: LocalizationService.tr('sendResetLink', currentLocale),
            onPressed: _resetPassword,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.pop(),
              child: Text(LocalizationService.tr('backToSignIn', currentLocale)),
            ),
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
        const SizedBox(height: 32),
        Text(
          LocalizationService.tr('emailSent', currentLocale),
          style: AppTypography.displaySmall,
        ),
        const SizedBox(height: 16),
        Text(
          LocalizationService.tr('emailSentDesc', currentLocale),
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
