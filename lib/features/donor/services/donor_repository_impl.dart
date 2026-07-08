import '../../../core/network/api_service.dart';
import '../../../core/network/supabase_client.dart';
import '../../../shared/models/user_profile.dart';
import './donor_repository.dart';

class DonorRepositoryImpl implements DonorRepository {
  final SupabaseClientService _supabase;
  final ApiService _api;

  DonorRepositoryImpl(this._supabase, this._api);

  @override
  Future<List<UserProfile>> getNearbyDonors({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? bloodGroup,
    bool? isAvailable,
  }) async {
    var query = _supabase.client
        .from('profiles')
        .select()
        .eq('role', 'donor') as dynamic;

    if (bloodGroup != null) {
      query = query.eq('blood_group', bloodGroup);
    }
    if (isAvailable != null) {
      query = query.eq('is_available', isAvailable);
    }

    final data = await query as List;

    return data
        .map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<UserProfile?> getDonorById(String id) async {
    final data = await _api.querySingle('profiles', 'id', id);
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  @override
  Future<List<UserProfile>> searchDonors(String query) async {
    final data = await _supabase.client
        .from('profiles')
        .select()
        .eq('role', 'donor')
        .ilike('name', '%$query%') as List;
    return data
        .map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<UserProfile> updateDonorProfile(UserProfile donor) async {
    await _api.update('profiles', donor.toJson(), 'id', donor.id);
    final data = await _api.querySingle('profiles', 'id', donor.id);
    return UserProfile.fromJson(data!);
  }

  @override
  Future<void> toggleAvailability(String donorId, bool isAvailable) async {
    await _api.update('profiles', {'is_available': isAvailable}, 'id', donorId);
  }
}
