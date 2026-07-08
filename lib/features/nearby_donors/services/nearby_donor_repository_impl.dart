import '../../../core/network/supabase_client.dart';
import '../../../shared/models/user_profile.dart';
import './nearby_donor_repository.dart';

class NearbyDonorRepositoryImpl implements NearbyDonorRepository {
  final SupabaseClientService _supabase;

  NearbyDonorRepositoryImpl(this._supabase);

  @override
  Future<List<UserProfile>> findNearbyDonors({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    String? bloodGroup,
  }) async {
    var query = _supabase.client
        .from('profiles')
        .select()
        .eq('role', 'donor')
        .eq('is_available', true) as dynamic;

    if (bloodGroup != null) {
      query = query.eq('blood_group', bloodGroup);
    }

    final data = await query as List;
    return data
        .map((e) => UserProfile.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
