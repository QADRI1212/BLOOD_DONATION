import '../../../shared/models/user_profile.dart';

abstract class NearbyDonorRepository {
  Future<List<UserProfile>> findNearbyDonors({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    String? bloodGroup,
  });
}
