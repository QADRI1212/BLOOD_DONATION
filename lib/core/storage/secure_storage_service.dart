import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/logger_service.dart';

/// Service that wraps [FlutterSecureStorage] for storing sensitive data
/// such as JWT tokens, session keys, and user credentials.
///
/// Uses platform-specific secure storage:
/// - Android: EncryptedSharedPreferences (API 23+) / AES encryption
/// - iOS: Keychain Services
/// - Web: LocalStorage (not truly secure)
///
/// All methods are safe to call before initialization (they will auto-initialize).
class SecureStorageService {
  static SecureStorageService? _instance;
  final LoggerService _logger = LoggerService();
  final FlutterSecureStorage _storage;

  SecureStorageService._internal()
      : _storage = const FlutterSecureStorage(
          aOptions: AndroidOptions(),
        );

  factory SecureStorageService() {
    _instance ??= SecureStorageService._internal();
    return _instance!;
  }

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  /// Key prefixes to avoid collisions with other data.
  static const String _tokenPrefix = 'auth_';
  static const String _userPrefix = 'user_';

  /// Key for the Supabase session token.
  static const String sessionTokenKey = '${_tokenPrefix}session_token';

  /// Key for the refresh token (if Supabase provides one).
  static const String refreshTokenKey = '${_tokenPrefix}refresh_token';

  /// Key for the user ID for session restore.
  static const String userIdKey = '${_userPrefix}user_id';

  /// Key for the user role for quick access.
  static const String userRoleKey = '${_userPrefix}role';

  // ---------------------------------------------------------------------------
  // Session Tokens
  // ---------------------------------------------------------------------------

  /// Store the session token securely.
  Future<void> saveSessionToken(String token) async {
    try {
      await _storage.write(key: sessionTokenKey, value: token);
    } catch (e, stack) {
      _logger.error('Failed to save session token', error: e, stackTrace: stack);
    }
  }

  /// Retrieve the stored session token.
  Future<String?> getSessionToken() async {
    try {
      return await _storage.read(key: sessionTokenKey);
    } catch (e, stack) {
      _logger.error('Failed to read session token', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Store the refresh token.
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: refreshTokenKey, value: token);
    } catch (e, stack) {
      _logger.error('Failed to save refresh token', error: e, stackTrace: stack);
    }
  }

  /// Retrieve the stored refresh token.
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: refreshTokenKey);
    } catch (e, stack) {
      _logger.error('Failed to read refresh token', error: e, stackTrace: stack);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // User Metadata
  // ---------------------------------------------------------------------------

  /// Store the user ID for session identification.
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: userIdKey, value: userId);
    } catch (e, stack) {
      _logger.error('Failed to save user ID', error: e, stackTrace: stack);
    }
  }

  /// Retrieve the stored user ID.
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: userIdKey);
    } catch (e, stack) {
      _logger.error('Failed to read user ID', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Store the user role for quick auth checks.
  Future<void> saveUserRole(String role) async {
    try {
      await _storage.write(key: userRoleKey, value: role);
    } catch (e, stack) {
      _logger.error('Failed to save user role', error: e, stackTrace: stack);
    }
  }

  /// Retrieve the stored user role.
  Future<String?> getUserRole() async {
    try {
      return await _storage.read(key: userRoleKey);
    } catch (e, stack) {
      _logger.error('Failed to read user role', error: e, stackTrace: stack);
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Persist full auth bundle
  // ---------------------------------------------------------------------------

  /// Save complete auth session data at once.
  Future<void> saveAuthSession({
    required String userId,
    String? sessionToken,
    String? refreshToken,
    String? role,
  }) async {
    await saveUserId(userId);
    if (sessionToken != null) await saveSessionToken(sessionToken);
    if (refreshToken != null) await saveRefreshToken(refreshToken);
    if (role != null) await saveUserRole(role);
    _logger.info('Auth session saved securely for user $userId');
  }

  // ---------------------------------------------------------------------------
  // Clear
  // ---------------------------------------------------------------------------

  /// Remove all stored auth data (used on logout).
  Future<void> clearAuthSession() async {
    try {
      await Future.wait([
        _storage.delete(key: sessionTokenKey),
        _storage.delete(key: refreshTokenKey),
        _storage.delete(key: userIdKey),
        _storage.delete(key: userRoleKey),
      ]);
      _logger.info('Auth session cleared from secure storage');
    } catch (e, stack) {
      _logger.error('Failed to clear auth session', error: e, stackTrace: stack);
    }
  }

  /// Clear all stored data from secure storage.
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.info('All secure storage data cleared');
    } catch (e, stack) {
      _logger.error('Failed to clear all secure storage', error: e, stackTrace: stack);
    }
  }
}
