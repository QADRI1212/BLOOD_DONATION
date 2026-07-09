import '../../../shared/models/user_profile.dart';
import './auth_repository.dart';

class AuthUseCases {
  final AuthRepository _repository;

  AuthUseCases(this._repository);

  Future<UserProfile?> login(String email, String password) {
    return _repository.login(email: email, password: password);
  }

  Future<UserProfile?> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'donor',
  }) {
    return _repository.signUp(email: email, password: password, name: name, phone: phone, role: role);
  }

  Future<void> logout() => _repository.logout();

  Future<void> resetPassword(String email) => _repository.resetPassword(email);

  Future<UserProfile?> getCurrentProfile() => _repository.getCurrentProfile();

  Future<UserProfile> updateProfile(UserProfile profile) {
    return _repository.updateProfile(profile);
  }

  bool get isAuthenticated => _repository.isAuthenticated;
}
