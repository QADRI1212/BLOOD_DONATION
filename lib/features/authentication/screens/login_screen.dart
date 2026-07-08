import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/errors/error_messages.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_textfield.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToRoleScreen(BuildContext context, String role) {
    switch (role) {
      case 'patient':
        context.go('/patient');
        break;
      case 'hospital':
        context.go('/hospital-dashboard');
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

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authProvider.notifier).login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentLocale = ref.watch(localeProvider);

    ref.listen<AsyncValue<UserProfile?>>(authProvider, (prev, next) {
      next.whenOrNull(
        data: (user) {
          if (user != null) {
            _navigateToRoleScreen(context, user.role);
          }
        },
        error: (error, _) {
          final locale = ref.read(localeProvider);
          final errorMessage = getUserFriendlyMessage(error);
          final isUnverifiedEmail =
              errorMessage.toLowerCase().contains('verify your email') ||
              errorMessage.toLowerCase().contains('email not confirmed') ||
              errorMessage.toLowerCase().contains('email not verified');

          if (isUnverifiedEmail) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.warning,
                duration: const Duration(seconds: 8),
                action: SnackBarAction(
                  label: LocalizationService.tr('verify', locale),
                  textColor: Colors.white,
                  onPressed: () => context.go(
                    '/auth/login/verify-email',
                    extra: _emailController.text.trim(),
                  ),
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                behavior: SnackBarBehavior.floating,
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      );
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Logo area
                Center(
                  child: SvgPicture.asset(
                    'assets/svg/logo.svg',
                    width: 220,
                    height: 80,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  LocalizationService.tr('welcomeBack', currentLocale),
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Email
                AppTextField(
                  controller: _emailController,
                  label: LocalizationService.tr('email', currentLocale),
                  hint: LocalizationService.tr('enterEmail', currentLocale),
                  isEmail: true,
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 20),
                // Password
                AppTextField(
                  controller: _passwordController,
                  label: LocalizationService.tr('password', currentLocale),
                  hint: LocalizationService.tr('enterPassword', currentLocale),
                  isPassword: true,
                  prefixIcon: Icons.lock_outlined,
                ),
                const SizedBox(height: 12),
                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.go('/auth/login/forgot-password'),
                    child: Text(LocalizationService.tr('forgotPassword', currentLocale)),
                  ),
                ),
                const SizedBox(height: 24),
                // Login button
                AppButton(
                  label: LocalizationService.tr('signIn', currentLocale),
                  onPressed: _login,
                  isLoading: authState.isLoading,
                ),
                const SizedBox(height: 24),
                // Register link
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        LocalizationService.tr('dontHaveAccount', currentLocale),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.grey500,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/auth/login/register'),
                        child: Text(LocalizationService.tr('signUp', currentLocale)),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
