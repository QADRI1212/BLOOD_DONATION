import '../../../shared/models/hospital.dart';

abstract class BloodBankRepository {
  Future<List<BloodBank>> getBloodBanks({
    String? query,
    double? latitude,
    double? longitude,
    double radiusKm,
  });

  Future<BloodBank?> getBloodBankById(String id);
}
