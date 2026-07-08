import 'dart:async' show StreamSubscription;
import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/services/logger_service.dart';
import '../../core/services/analytics_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/network/supabase_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/constants/app_constants.dart';
import '../models/user_profile.dart';

// Auth State - Riverpod Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final LoggerService _logger = LoggerService();
  final SupabaseClientService _supabase = SupabaseClientService();
  StreamSubscription<AuthState>? _authSubscription;

  AuthNotifier() : super(const AsyncValue.data(null)) {
    _checkSession();
    _listenToAuthChanges();
  }

  /// Listen for auth events.
  /// Password recovery: navigate to the reset-password screen.
  /// Email verification is handled by [EmailVerificationScreen]'s own
  /// [onAuthStateChange] listener when the user is on that screen.
  void _listenToAuthChanges() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((event) {
      if (event.event == AuthChangeEvent.passwordRecovery) {
        _logger.info(
            'Password recovery event received — navigating to reset screen');
        AuthStateProvider().setRecoveryMode(true);
      }
    });
  }

  /// Update the user's password after a password recovery flow.
  Future<void> updatePassword(String newPassword) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      _logger.info('Password updated successfully');
      // Clear recovery mode so the router stops redirecting to reset-password
      AuthStateProvider().setRecoveryMode(false);
      // Sign out so the user can log in with their new password
      await _supabase.auth.signOut();
      // Update the router's auth state so it knows the user is signed out
      AuthStateProvider().updateAuthState(authenticated: false);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      _logger.error('Failed to update password', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Test-only constructor — skips _checkSession() so widget tests don't
  /// need a live Supabase connection.
  AuthNotifier.test() : super(const AsyncValue.data(null));

  bool get isAuthenticated => _supabase.isAuthenticated;

  String? get userRole => state.valueOrNull?.role;

  Future<void> _checkSession() async {
    try {
      // First try Supabase's built-in session restore
      final session = _supabase.auth.currentSession;
      if (session != null) {
        // Persist to secure storage for redundancy
        await SecureStorageService().saveAuthSession(
          userId: session.user.id,
          sessionToken: session.accessToken,
          refreshToken: session.refreshToken,
          role: session.user.userMetadata?['role'] as String?,
        );
        await _loadProfile();
        return;
      }

      // Fallback: try to restore session from secure storage
      await _tryRestoreFromSecureStorage();
    } catch (e, stack) {
      _logger.error('Session check failed', error: e, stackTrace: stack);
      state = const AsyncValue.data(null);
    }
  }

  /// Attempt to restore a session from secure storage.
  /// This provides resilience if Supabase's internal session cache is cleared.
  Future<void> _tryRestoreFromSecureStorage() async {
    try {
      final secure = SecureStorageService();
      final accessToken = await secure.getSessionToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        _logger.info('Found stored access token, attempting session restore...');
        try {
          final response = await _supabase.auth.setSession(accessToken);
          if (response.user != null) {
            await _loadProfile();
            return;
          }
        } catch (_) {
          // Session restore failed - token expired or invalid
          _logger.warning('Stored session expired, clearing secure storage');
          await secure.clearAuthSession();
        }
      }
    } catch (e) {
      _logger.warning('Failed to restore from secure storage: $e');
    }
  }

  Future<void> _loadProfile() async {
    try {
      final user = _supabase.currentUser;
      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final response = await _supabase.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      final profile = UserProfile.fromJson(Map<String, dynamic>.from(response));
      state = AsyncValue.data(profile);

      // Upload FCM token on session restore too
      _uploadFcmTokenIfAvailable(user.id);
    } catch (e, stack) {
      _logger.error('Failed to load profile', error: e, stackTrace: stack);
      state = const AsyncValue.data(null);
    }
  }

  /// Upload the device's FCM push token to the user's profile so the server
  /// can send targeted push notifications.
  Future<void> _uploadFcmTokenIfAvailable(String userId) async {
    try {
      final token = NotificationService().fcmToken;
      if (token != null && token.isNotEmpty) {
        await _supabase.client.from('profiles').update({
          'fcm_token': token,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        _logger.info('FCM token uploaded for user $userId');
      }
    } catch (e) {
      // Non-critical - don't block the user
      _logger.warning('Failed to upload FCM token: $e');
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'donor',
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone ?? '', 'role': role},
        emailRedirectTo: 'com.blooddonation.app://verify',
      );

      if (response.user == null) {
        throw AuthenticationException('Sign up failed');
      }

      final token = NotificationService().fcmToken;
      // Profile is auto-created by the handle_new_user trigger on signup,
      // so we UPDATE it with the additional details instead of INSERT.
      await _supabase.client.from('profiles').update({
        'name': name,
        'phone': phone,
        'role': role,
        'is_available': false,
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', response.user!.id);

      // When 'Confirm email' is ON in the Supabase Dashboard, the
      // API returns session=null (user is NOT auto-signed-in).
      _logger.info(
          'SignUp response — session: '
          '${response.session != null ? "present" : "null"}, '
          'emailConfirmedAt: '
          '${response.user?.emailConfirmedAt}');

      if (response.session != null) {
        // Auto-confirm enabled — user is signed in directly
        await _loadProfile();
      } else {
        // Email confirmation required — user must verify first
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      _logger.error('Sign up failed', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// Sign in with Google OAuth via Supabase.
  ///
  /// Opens a browser for OAuth. After the user authenticates, Supabase
  /// redirects back to the app via the deep link and restores the session.
  /// We listen to [onAuthStateChange] to detect when the session is restored.
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw AuthenticationException('Invalid credentials');
      }

      // Check if user is suspended before completing login
      final profileData = await _supabase.client
          .from('profiles')
          .select('is_suspended')
          .eq('id', response.user!.id)
          .single();

      if (profileData['is_suspended'] == true) {
        // Sign them out immediately - suspended users cannot use the app
        await _supabase.auth.signOut();
        throw AuthenticationException(
          'Your account has been suspended. Please contact an administrator for assistance.'
        );
      }

      // Persist session tokens to secure storage
      final session = response.session;
      if (session != null) {
        await SecureStorageService().saveAuthSession(
          userId: response.user!.id,
          sessionToken: session.accessToken,
          refreshToken: session.refreshToken,
          role: response.user!.userMetadata?['role'] as String?,
        );
      }

      await _loadProfile();

      // Upload FCM token after successful login
      _uploadFcmTokenIfAvailable(response.user!.id);
    } catch (e, stack) {
      _logger.error('Login failed', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// Resend the email verification code.
  Future<void> resendVerificationEmail(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'com.blooddonation.app://verify',
      );
      _logger.info('Verification email resent to $email');
    } catch (e, stack) {
      _logger.error('Failed to resend verification email',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Verify the email OTP code.
  Future<void> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final response = await _supabase.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: token,
    );
    if (response.user != null) {
      // Reload profile to get fresh data
      await _loadProfile();
    }
  }

  /// Public wrapper to reload the user's profile from the database.
  Future<void> loadProfile() async {
    await _loadProfile();
  }

  Future<void> logout() async {
    try {
      // Clear secure storage first (so tokens are gone even if signOut fails)
      await SecureStorageService().clearAuthSession();
      // Clear analytics user data
      await AnalyticsService().clearUserData();
      await _supabase.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      _logger.error('Logout failed', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
    }
  }

  /// Send a password reset email with a magic link.
  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.blooddonation.app://verify',
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      _logger.error('Reset password failed', error: e, stackTrace: stack);
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    final previousState = state;
    try {
      await _supabase.client
          .from('profiles')
          .update(updatedProfile.toJson())
          .eq('id', updatedProfile.id);

      state = AsyncValue.data(updatedProfile);
    } catch (e, stack) {
      _logger.error('Update profile failed', error: e, stackTrace: stack);
      // Keep previous state on failure — don't set error (which would null the user)
      state = previousState;
      rethrow; // Let the caller know the save failed so they can show an error
    }
  }
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserProfile?>>(
  (ref) => AuthNotifier(),
);

// ChangeNotifier-based auth state for GoRouter redirects
// Uses a static singleton so the onboarding screen can access it easily.
class AuthStateProvider extends ChangeNotifier {
  static AuthStateProvider? _instance;
  factory AuthStateProvider() {
    _instance ??= AuthStateProvider._();
    return _instance!;
  }
  AuthStateProvider._() {
    _loadOnboardingState();
  }

  bool _isAuthenticated = false;
  bool _isOnboardingComplete = false;
  bool _isOnboardingLoading = true; // true until SharedPreferences confirms state
  bool _isRecoveryMode = false;
  String? _userRole;

  bool get isAuthenticated => _isAuthenticated;
  bool get isOnboardingComplete => _isOnboardingComplete;
  bool get isOnboardingLoading => _isOnboardingLoading;
  bool get isRecoveryMode => _isRecoveryMode;
  String? get userRole => _userRole;

  /// Set by AuthNotifier when the password recovery event fires.
  void setRecoveryMode(bool value) {
    _isRecoveryMode = value;
    notifyListeners();
  }

  /// Load onboarding completion state from SharedPreferences.
  Future<void> _loadOnboardingState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isOnboardingComplete = prefs.getBool(AppConstants.onboardingCompletedKey) ?? false;
    } catch (_) {
      _isOnboardingComplete = false;
    } finally {
      _isOnboardingLoading = false;
      notifyListeners();
    }
  }

  /// Mark onboarding as complete and persist to SharedPreferences.
  Future<void> completeOnboarding() async {
    _isOnboardingComplete = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingCompletedKey, true);
    } catch (_) {
      // Non-critical — user won't lose much if persistence fails
    }
  }

  void updateAuthState({required bool authenticated, String? role}) {
    _isAuthenticated = authenticated;
    _userRole = role;
    notifyListeners();
  }

  void setOnboardingComplete(bool complete) {
    _isOnboardingComplete = complete;
    notifyListeners();
  }

  void clear() {
    _isAuthenticated = false;
    _userRole = null;
    notifyListeners();
  }
}
