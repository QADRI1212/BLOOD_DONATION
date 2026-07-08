import '../../../shared/models/hospital.dart';
import './blood_bank_repository.dart';

class BloodBankUseCases {
  final BloodBankRepository _repository;

  BloodBankUseCases(this._repository);

  Future<List<BloodBank>> searchBloodBanks(String query) {
    return _repository.getBloodBanks(query: query);
  }

  Future<List<BloodBank>> getNearbyBloodBanks({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
  }) {
    return _repository.getBloodBanks(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }

  Future<BloodBank?> getBloodBankById(String id) {
    return _repository.getBloodBankById(id);
  }
}
