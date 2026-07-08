import '../../../shared/models/hospital.dart';
import './hospital_repository.dart';

class HospitalUseCases {
  final HospitalRepository _repository;

  HospitalUseCases(this._repository);

  Future<List<Hospital>> searchHospitals(String query) {
    return _repository.getHospitals(query: query);
  }

  Future<List<Hospital>> getNearbyHospitals({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
  }) {
    return _repository.getHospitals(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }

  Future<Hospital?> getHospitalById(String id) {
    return _repository.getHospitalById(id);
  }

  Future<List<Hospital>> getSavedHospitals(String userId) {
    return _repository.getSavedHospitals(userId);
  }

  Future<void> saveHospital(String userId, String hospitalId) {
    return _repository.saveHospital(userId, hospitalId);
  }

  Future<void> removeSavedHospital(String userId, String hospitalId) {
    return _repository.removeSavedHospital(userId, hospitalId);
  }
}
