import '../../../core/network/supabase_client.dart';
import '../../../shared/models/user_profile.dart';
import './auth_repository.dart';
import './auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClientService _supabase;
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._supabase)
      : _remoteDataSource = AuthRemoteDataSource(_supabase);

  @override
  Future<UserProfile?> login({
    required String email,
    required String password,
  }) async {
    await _remoteDataSource.login(email, password);
    return getCurrentProfile();
  }

  @override
  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'donor',
  }) async {
    await _remoteDataSource.signUp(email: email, password: password, name: name, phone: phone, role: role);
    return getCurrentProfile();
  }

  @override
  Future<void> logout() => _remoteDataSource.logout();

  @override
  Future<void> resetPassword(String email) => _remoteDataSource.resetPassword(email);

  @override
  Future<UserProfile?> getCurrentProfile() async {
    final user = _supabase.currentUser;
    if (user == null) return null;
    final response = await _supabase.client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .single();
    return UserProfile.fromJson(Map<String, dynamic>.from(response));
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _supabase.client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
    return profile;
  }

  @override
  bool get isAuthenticated => _supabase.isAuthenticated;
}
