import 'dart:async' show StreamSubscription, Timer;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResending = false;
  bool _isChecking = false;
  bool _isVerified = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _listenForEmailVerification();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Listen for when the user clicks the verification link in their email.
  /// The deep link triggers an [AuthChangeEvent.signedIn] event with
  /// [emailConfirmedAt] populated. When detected, we sign out (so the user
  /// must log in with their password) and navigate to the login screen.
  void _listenForEmailVerification() {
    _authSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedIn ||
          authState.event == AuthChangeEvent.tokenRefreshed) {
        final user = authState.session?.user;
        if (user != null && user.emailConfirmedAt != null) {
          _onEmailVerified();
        }
      }
    });
  }

  Future<void> _onEmailVerified() async {
    if (_isVerified) return;
    _isVerified = true;

    _authSubscription?.cancel();

    // Sign out so the user must log in with their password
    await Supabase.instance.client.auth.signOut();

    if (mounted) {
      final locale = ref.read(localeProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationService.tr('emailVerifiedSuccess', locale),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/auth/login');
    }
  }

  Future<void> _resendEmail() async {
    setState(() => _isResending = true);
    try {
      await ref.read(authProvider.notifier).resendVerificationEmail(
            widget.email,
          );
      _startCooldown();
      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        final locale = ref.read(localeProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService
                      .tr('failedToSendCode', locale)
                      .replaceAll('{error}', '$e'),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  /// Manually check if the email has been verified (e.g. user clicked the
  /// link in another browser / on another device).
  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true);
    try {
      final response =
          await Supabase.instance.client.auth.getUser();
      if (response.user?.emailConfirmedAt != null) {
        await _onEmailVerified();
        return;
      }
      if (mounted) {
        final locale = ref.read(localeProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.tr('emailNotYetVerified', locale),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } catch (e) {
      // getUser() may fail if there's no session — that's expected
      // since we signed the user out after signup.
      if (mounted) {
        final locale = ref.read(localeProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocalizationService.tr('emailNotYetVerified', locale),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.warning,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _startCooldown() {
    _resendCooldown = 30;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _resendCooldown--;
      });
      if (_resendCooldown <= 0) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Mail icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 56,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                LocalizationService.tr('checkYourEmail', currentLocale),
                style: AppTypography.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                LocalizationService.tr('verificationLinkSentTo', currentLocale),
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),

              // Instructions card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.infoContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInstructionRow(
                      Icons.email_outlined,
                      LocalizationService.tr(
                          'checkInboxInstruction', currentLocale),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionRow(
                      Icons.warning_amber_outlined,
                      LocalizationService.tr(
                          'checkSpamInstruction', currentLocale),
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionRow(
                      Icons.touch_app_outlined,
                      LocalizationService.tr(
                          'clickLinkInstruction', currentLocale),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // "I've verified" button
              AppButton(
                label: LocalizationService.tr(
                    'iveVerifiedEmail', currentLocale),
                onPressed: _checkVerificationStatus,
                isLoading: _isChecking,
              ),
              const SizedBox(height: 16),

              // Resend section
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    LocalizationService.tr(
                        'didNotReceiveEmail', currentLocale),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.grey500,
                    ),
                  ),
                  if (_resendCooldown > 0)
                    Text(
                      ' ${_resendCooldown}s',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.grey400,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    GestureDetector(
                      onTap: _isResending ? null : _resendEmail,
                      child: Text(
                        LocalizationService.tr('resend', currentLocale),
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 32),

              // Back to login
              TextButton(
                onPressed: () => context.go('/auth/login'),
                child: Text(
                  LocalizationService.tr('backToSignIn', currentLocale),
                ),
              ),
              const SizedBox(height: 16),

              // Use different email
              TextButton(
                onPressed: () => context.go('/auth/login/register'),
                child: Text(
                  LocalizationService.tr('useDifferentEmail', currentLocale),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.grey500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.info),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.grey700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
