import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/donation.dart';

class DonationRemoteDataSource {
  static const String _cacheBox = 'cached_donations';
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  DonationRemoteDataSource(this._api);

  Future<List<Donation>> getDonationHistory(String donorId, {int? limit, int? offset}) async {
    try {
      final data = await _api.query(
        'donations',
        column: 'donor_id',
        value: donorId,
        orderBy: 'donation_date',
        ascending: false,
        limit: limit,
        offset: offset,
        cacheBox: _cacheBox,
      );
      return data.map((e) => Donation.fromJson(e)).toList();
    } catch (e, stack) {
      _logger.error('Failed to get donation history', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<DonationStats> getDonationStats(String donorId) async {
    try {
      final data = await _api.query(
        'donations',
        column: 'donor_id',
        value: donorId,
        orderBy: 'donation_date',
        ascending: false,
        cacheBox: _cacheBox,
      );

      if (data.isEmpty) {
        return const DonationStats();
      }

      final totalUnits = data.fold<int>(
        0,
        (sum, d) => sum + ((d['units'] as num?)?.toInt() ?? 0),
      );

      final donationDateStr = data.first['donation_date'];
      final lastDonationDate = donationDateStr is String
          ? DateTime.tryParse(donationDateStr)
          : null;

      return DonationStats(
        totalDonations: data.length,
        totalUnits: totalUnits,
        lastDonationDate: lastDonationDate,
        nextEligibleDate: lastDonationDate?.add(const Duration(days: 90)),
        lastHospitalName: data.first['hospital_name'] as String?,
      );
    } catch (e, stack) {
      _logger.error('Failed to get donation stats', error: e, stackTrace: stack);
      rethrow;
    }
  }

  Future<Donation> recordDonation(Donation donation) async {
    try {
      final json = donation.toJson();
      // Remove 'id' so the DB auto-generates a valid UUID via uuid_generate_v4().
      // Passing an empty string would fail the UUID column constraint.
      json.remove('id');
      final data = await _api.insert('donations', json);
      return Donation.fromJson(data);
    } catch (e, stack) {
      _logger.error('Failed to record donation', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
