import '../../../shared/models/donation.dart';

abstract class DonationRepository {
  Future<List<Donation>> getDonationHistory(String donorId);

  Future<DonationStats> getDonationStats(String donorId);

  Future<Donation> recordDonation(Donation donation);
}
