import '../../../shared/models/donation.dart';
import './donation_repository.dart';

class DonationUseCases {
  final DonationRepository _repository;

  DonationUseCases(this._repository);

  Future<List<Donation>> getDonationHistory(String donorId) {
    return _repository.getDonationHistory(donorId);
  }

  Future<DonationStats> getDonationStats(String donorId) {
    return _repository.getDonationStats(donorId);
  }

  Future<Donation> recordDonation(Donation donation) {
    return _repository.recordDonation(donation);
  }
}
