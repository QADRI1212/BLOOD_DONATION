import '../../../core/network/api_service.dart';
import '../../../shared/models/hospital.dart';
import './hospital_repository.dart';

class HospitalRepositoryImpl implements HospitalRepository {
  final ApiService _api;

  HospitalRepositoryImpl(this._api);

  @override
  Future<List<Hospital>> getHospitals({
    String? query,
    double? latitude,
    double? longitude,
    double radiusKm = 25,
    bool? verified,
  }) async {
    final filters = <String, dynamic>{'verified': ?verified};
    final data = await _api.query(
      'hospitals',
      filters: filters,
      orderBy: 'name',
    );
    return data.map((e) => Hospital.fromJson(e)).toList();
  }

  @override
  Future<Hospital?> getHospitalById(String id) async {
    final data = await _api.querySingle('hospitals', 'id', id);
    if (data == null) return null;
    return Hospital.fromJson(data);
  }

  @override
  Future<List<Hospital>> getSavedHospitals(String userId) async {
    final data = await _api.query(
      'saved_locations',
      column: 'user_id',
      value: userId,
    );
    return data.map((e) => Hospital.fromJson(e)).toList();
  }

  @override
  Future<void> saveHospital(String userId, String hospitalId) async {
    await _api.insert('saved_locations', {
      'user_id': userId,
      'hospital_id': hospitalId,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> removeSavedHospital(String userId, String hospitalId) async {
    await _api.delete('saved_locations', 'user_id', userId);
  }
}
