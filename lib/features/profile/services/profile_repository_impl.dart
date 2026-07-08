import '../../../core/network/api_service.dart';
import '../../../shared/models/user_profile.dart';
import './profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ApiService _api;

  ProfileRepositoryImpl(this._api);

  @override
  Future<UserProfile?> getProfile(String userId) async {
    final data = await _api.querySingle('profiles', 'id', userId);
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    await _api.update(
      'profiles',
      profile.toJson(),
      'id',
      profile.id,
    );
    final data = await _api.querySingle('profiles', 'id', profile.id);
    return UserProfile.fromJson(data!);
  }

  @override
  Future<void> updateAvatar(String userId, String imageUrl) async {
    await _api.update(
      'profiles',
      {'avatar_url': imageUrl, 'updated_at': DateTime.now().toIso8601String()},
      'id',
      userId,
    );
  }

  @override
  Future<void> deleteAccount(String userId) async {
    await _api.delete('profiles', 'id', userId);
  }
}
