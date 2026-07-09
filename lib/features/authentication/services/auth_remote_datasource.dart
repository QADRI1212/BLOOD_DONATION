import '../../../core/network/supabase_client.dart';
import '../../../core/errors/app_exceptions.dart';
import '../../../core/services/logger_service.dart';

class AuthRemoteDataSource {
  final SupabaseClientService _supabase;
  final LoggerService _logger = LoggerService();

  AuthRemoteDataSource(this._supabase);

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const AuthenticationException('Invalid credentials');
      }
      return {
        'success': true,
        'user_id': response.user!.id,
        'email_verified': response.user!.emailConfirmedAt != null,
      };
    } on AuthenticationException {
      rethrow;
    } catch (e, stack) {
      _logger.error('Login failed', error: e, stackTrace: stack);
      throw ServerException('Login failed. Please try again.');
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'donor',
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name, 'phone': phone ?? '', 'role': role},
      );
      if (response.user == null) {
        throw const AuthenticationException('Sign up failed');
      }
      await _supabase.client.from('profiles').update({
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'is_available': false,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', response.user!.id);
      return {
        'success': true,
        'user_id': response.user!.id,
        'email_verified': false,
      };
    } on AuthenticationException {
      rethrow;
    } catch (e, stack) {
      _logger.error('Sign up failed', error: e, stackTrace: stack);
      throw ServerException('Sign up failed. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e, stack) {
      _logger.error('Logout failed', error: e, stackTrace: stack);
      throw ServerException('Logout failed');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e, stack) {
      _logger.error('Password reset failed', error: e, stackTrace: stack);
      throw ServerException('Password reset failed');
    }
  }
}
