import '../../../shared/models/user_profile.dart';

abstract class DonorRepository {
  Future<List<UserProfile>> getNearbyDonors({
    required double latitude,
    required double longitude,
    required double radiusKm,
    String? bloodGroup,
    bool? isAvailable,
  });

  Future<UserProfile?> getDonorById(String id);

  Future<List<UserProfile>> searchDonors(String query);

  Future<UserProfile> updateDonorProfile(UserProfile donor);

  Future<void> toggleAvailability(String donorId, bool isAvailable);
}
