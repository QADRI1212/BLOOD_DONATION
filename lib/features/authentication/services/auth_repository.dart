import '../../../shared/models/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile?> login({
    required String email,
    required String password,
  });

  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'donor',
  });

  Future<void> logout();

  Future<void> resetPassword(String email);

  Future<UserProfile?> getCurrentProfile();

  Future<UserProfile> updateProfile(UserProfile profile);

  bool get isAuthenticated;
}
