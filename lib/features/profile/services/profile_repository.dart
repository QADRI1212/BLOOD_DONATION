import '../../../shared/models/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getProfile(String userId);

  Future<UserProfile> updateProfile(UserProfile profile);

  Future<void> updateAvatar(String userId, String imageUrl);

  Future<void> deleteAccount(String userId);
}
