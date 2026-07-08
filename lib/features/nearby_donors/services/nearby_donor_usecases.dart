import '../../../shared/models/user_profile.dart';
import './nearby_donor_repository.dart';

class NearbyDonorUseCases {
  final NearbyDonorRepository _repository;

  NearbyDonorUseCases(this._repository);

  Future<List<UserProfile>> findNearbyDonors({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    String? bloodGroup,
  }) {
    return _repository.findNearbyDonors(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      bloodGroup: bloodGroup,
    );
  }
}
