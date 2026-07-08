import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// A widget that displays an error state with an icon, message, and optional retry button.
///
/// Use this widget when a data fetch fails or an error occurs in a feature screen.
/// Examples:
/// ```dart
/// ErrorState(
///   icon: Icons.cloud_off_rounded,
///   title: 'Network Error',
///   message: 'Unable to connect. Please check your internet connection.',
///   onRetry: () => ref.invalidate(myProvider),
/// )
/// ```
class ErrorState extends StatelessWidget {
  /// The icon displayed at the top. Defaults to [Icons.error_outline].
  final IconData icon;

  /// The primary error title.
  final String title;

  /// Optional detailed error message shown below the title.
  final String? message;

  /// Optional retry callback. When provided, a "Try Again" button is shown.
  final VoidCallback? onRetry;

  /// Optional custom action label for the retry button. Defaults to "Try Again".
  final String? retryLabel;

  /// Optional widget shown below the retry button (e.g. alternative actions).
  final Widget? footer;

  const ErrorState({
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.retryLabel,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),

            // Error title
            Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            // Error message
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey500,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: Text(retryLabel ?? 'Try Again'),
              ),
            ],

            // Footer widget
            if (footer != null) ...[
              const SizedBox(height: 16),
              footer!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A convenience wrapper that shows an [ErrorState] inside a scrollable
/// [RefreshIndicator] so the user can pull-to-refresh.
class RefreshableErrorState extends StatelessWidget {
  final VoidCallback? onRetry;
  final String title;
  final String? message;

  const RefreshableErrorState({
    super.key,
    this.onRetry,
    this.title = 'Something went wrong',
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRetry?.call(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 400,
          child: ErrorState(
            icon: Icons.error_outline_rounded,
            title: title,
            message: message,
            onRetry: onRetry,
          ),
        ),
      ),
    );
  }
}
