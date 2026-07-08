import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/user_profile.dart';

class ProfileRemoteDataSource {
  static const String _cacheBox = 'cached_profiles';
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  ProfileRemoteDataSource(this._api);

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final data = await _api.querySingle('profiles', 'id', userId,
        cacheBox: _cacheBox,
      );
      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e, stack) {
      _logger.error('Failed to get profile', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<UserProfile> updateProfile(UserProfile profile) async {
    try {
      await _api.update('profiles', profile.toJson(), 'id', profile.id);
      return profile;
    } catch (e, stack) {
      _logger.error('Failed to update profile', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> updateAvatar(String userId, String imageUrl) async {
    try {
      await _api.update(
        'profiles',
        {'avatar_url': imageUrl},
        'id',
        userId,
      );
    } catch (e, stack) {
      _logger.error('Failed to update avatar', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<void> deleteAccount(String userId) async {
    try {
      await _api.delete('profiles', 'id', userId);
    } catch (e, stack) {
      _logger.error('Failed to delete account', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
