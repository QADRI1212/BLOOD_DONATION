import '../../../core/network/api_service.dart';
import '../../../shared/models/hospital.dart';
import './blood_bank_repository.dart';

class BloodBankRepositoryImpl implements BloodBankRepository {
  final ApiService _api;

  BloodBankRepositoryImpl(this._api);

  @override
  Future<List<BloodBank>> getBloodBanks({
    String? query,
    double? latitude,
    double? longitude,
    double radiusKm = 25,
  }) async {
    final data = await _api.query('blood_banks', orderBy: 'name');
    return data.map((e) => BloodBank.fromJson(e)).toList();
  }

  @override
  Future<BloodBank?> getBloodBankById(String id) async {
    final data = await _api.querySingle('blood_banks', 'id', id);
    if (data == null) return null;
    return BloodBank.fromJson(data);
  }
}
