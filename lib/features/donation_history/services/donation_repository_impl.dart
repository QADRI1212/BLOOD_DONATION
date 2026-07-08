import '../../../core/network/api_service.dart';
import '../../../shared/models/donation.dart';
import './donation_repository.dart';

class DonationRepositoryImpl implements DonationRepository {
  final ApiService _api;

  DonationRepositoryImpl(this._api);

  @override
  Future<List<Donation>> getDonationHistory(String donorId) async {
    final data = await _api.query(
      'donations',
      column: 'donor_id',
      value: donorId,
      orderBy: 'donation_date',
      ascending: false,
    );
    return data.map((e) => Donation.fromJson(e)).toList();
  }

  @override
  Future<DonationStats> getDonationStats(String donorId) async {
    final history = await getDonationHistory(donorId);
    if (history.isEmpty) return const DonationStats();
    return DonationStats(
      totalDonations: history.length,
      totalUnits: history.fold(0, (sum, d) => sum + d.units),
      lastDonationDate: history.first.donationDate,
      lastHospitalName: history.first.hospitalName,
    );
  }

  @override
  Future<Donation> recordDonation(Donation donation) async {
    final data = await _api.insert('donations', donation.toJson());
    return Donation.fromJson(data);
  }
}
