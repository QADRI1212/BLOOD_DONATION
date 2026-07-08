import 'package:flutter/material.dart';
import 'app_exceptions.dart';
import '../services/logger_service.dart';
import '../services/crashlytics_service.dart';

class ErrorHandler {
  final LoggerService _logger = LoggerService();
  final CrashlyticsService _crashlytics = CrashlyticsService();

  String getUserFriendlyMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is FormatException) {
      return 'Invalid data format received';
    }

    _logger.error('Unhandled error', error: error);

    return 'Something went wrong. Please try again.';
  }

  void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getUserFriendlyMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
        ),
      ),
    );

    // Also log to Crashlytics
    logError(error, StackTrace.current);
  }

  Future<void> showErrorDialog(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    final message = getUserFriendlyMessage(error);
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
        ],
      ),
    );

    // Also log to Crashlytics
    logError(error, StackTrace.current);
  }

  void logError(dynamic error, StackTrace? stackTrace) {
    _logger.error(
      error.toString(),
      error: error,
      stackTrace: stackTrace,
    );
    _crashlytics.recordError(error, stackTrace);
  }
}
