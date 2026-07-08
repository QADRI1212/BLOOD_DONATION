import '../../../shared/models/user_profile.dart';
import './donor_repository.dart';

class DonorUseCases {
  final DonorRepository _repository;

  DonorUseCases(this._repository);

  Future<List<UserProfile>> getNearbyDonors({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    String? bloodGroup,
    bool? isAvailable,
  }) {
    return _repository.getNearbyDonors(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      bloodGroup: bloodGroup,
      isAvailable: isAvailable,
    );
  }

  Future<UserProfile?> getDonorById(String id) {
    return _repository.getDonorById(id);
  }

  Future<List<UserProfile>> searchDonors(String query) {
    return _repository.searchDonors(query);
  }

  Future<UserProfile> updateProfile(UserProfile donor) {
    return _repository.updateDonorProfile(donor);
  }

  Future<void> toggleAvailability(String donorId, bool isAvailable) {
    return _repository.toggleAvailability(donorId, isAvailable);
  }
}
