import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/cached_api_provider.dart';
import '../../../shared/models/user_profile.dart';
import '../services/profile_remote_datasource.dart';

final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSource(ref.read(cachedApiServiceProvider));
});

final profileProvider = FutureProvider.family<UserProfile?, String>((ref, userId) async {
  final dataSource = ref.read(profileRemoteDataSourceProvider);
  return dataSource.getProfile(userId);
});

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileRemoteDataSource _dataSource;

  ProfileNotifier(this._dataSource) : super(const AsyncValue.data(null));

  Future<void> updateProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.updateProfile(profile);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> updateAvatar(String userId, String imageUrl) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.updateAvatar(userId, imageUrl);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deleteAccount(String userId) async {
    state = const AsyncValue.loading();
    try {
      await _dataSource.deleteAccount(userId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
  return ProfileNotifier(ref.read(profileRemoteDataSourceProvider));
});
