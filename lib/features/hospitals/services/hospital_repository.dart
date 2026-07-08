import '../../../shared/models/hospital.dart';

abstract class HospitalRepository {
  Future<List<Hospital>> getHospitals({
    String? query,
    double? latitude,
    double? longitude,
    double radiusKm,
    bool? verified,
  });

  Future<Hospital?> getHospitalById(String id);

  Future<List<Hospital>> getSavedHospitals(String userId);

  Future<void> saveHospital(String userId, String hospitalId);

  Future<void> removeSavedHospital(String userId, String hospitalId);
}
