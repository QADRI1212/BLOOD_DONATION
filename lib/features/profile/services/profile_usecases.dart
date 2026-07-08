import '../../../shared/models/user_profile.dart';
import './profile_repository.dart';

class ProfileUseCases {
  final ProfileRepository _repository;

  ProfileUseCases(this._repository);

  Future<UserProfile?> getProfile(String userId) {
    return _repository.getProfile(userId);
  }

  Future<UserProfile> updateProfile(UserProfile profile) {
    return _repository.updateProfile(profile);
  }

  Future<void> updateAvatar(String userId, String imageUrl) {
    return _repository.updateAvatar(userId, imageUrl);
  }

  Future<void> deleteAccount(String userId) {
    return _repository.deleteAccount(userId);
  }
}
