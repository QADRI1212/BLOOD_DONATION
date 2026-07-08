import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks form validation state for authentication screens
final authFormValidProvider = StateProvider<bool>((ref) => false);

/// Tracks whether the user is currently submitting a form
final authSubmittingProvider = StateProvider<bool>((ref) => false);

/// Tracks whether the password is visible in password fields
final passwordVisibleProvider = StateProvider<bool>((ref) => false);
