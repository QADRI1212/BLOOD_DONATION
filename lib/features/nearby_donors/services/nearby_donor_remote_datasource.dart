import '../../../core/network/cached_api_service.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/geometry_utils.dart';
import '../../../shared/models/user_profile.dart';

class NearbyDonorRemoteDataSource {
  final CachedApiService _api;
  final LoggerService _logger = LoggerService();

  NearbyDonorRemoteDataSource(this._api);

  Future<List<UserProfile>> findNearbyDonors({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    String? bloodGroup,
    String sortBy = 'nearest',
  }) async {
    try {
      final filters = <String, dynamic>{'role': 'donor'};
      if (bloodGroup != null) filters['blood_group'] = bloodGroup;

      // Don't use cache for donor search - always fetch fresh data
      final data = await _api.query(
        'profiles',
        filters: filters,
        limit: 50,
      );

      _logger.info('Found ${data.length} donors in DB before distance filtering.');

      // Parse donors and calculate distances
      final donorsWithDistance = <_DonorWithDistance>[];
      for (final e in data) {
        final donor = UserProfile.fromJson(e);
        if (donor.latitude == null || donor.longitude == null) {
          _logger.info('Excluded donor ${donor.name} (${donor.id}) because location is null.');
          continue;
        }

        final distance = GeometryUtils.calculateDistanceInKm(
          latitude, longitude,
          donor.latitude!, donor.longitude!,
        );

        // If slider is maxed out at 100km, treat it as unlimited distance for testing
        final isWithin = radiusKm >= 100 || distance <= radiusKm;

        if (!isWithin) {
          _logger.info('Excluded donor ${donor.name} (${donor.id}) because distance $distance km > $radiusKm km.');
        } else {
          _logger.info('Included donor ${donor.name} (${donor.id}) at distance $distance km.');
          donorsWithDistance.add(_DonorWithDistance(donor: donor, distanceKm: distance));
        }
      }

      // For 'high_donations' sort, fetch donation counts from the donations table
      Map<String, int> donationCounts = {};
      if (sortBy == 'high_donations' && donorsWithDistance.isNotEmpty) {
        try {
          final donorIds = donorsWithDistance.map((d) => d.donor.id).toSet();
          final allDonations = await _api.query('donations', limit: 10000);
          for (final row in allDonations) {
            final donorId = row['donor_id'] as String?;
            if (donorId != null && donorIds.contains(donorId)) {
              donationCounts[donorId] = (donationCounts[donorId] ?? 0) + 1;
            }
          }
          _logger.info('Fetched donation counts for ${donationCounts.length} donors.');
        } catch (e) {
          _logger.warning('Failed to fetch donation counts for sorting: $e');
        }
      }

      // Sort based on the sortBy parameter
      switch (sortBy) {
        case 'nearest':
          donorsWithDistance.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
          break;
        case 'most_active':
          // Most recently active first — donors who donated most recently
          donorsWithDistance.sort((a, b) {
            final aDate = a.donor.lastDonationDate;
            final bDate = b.donor.lastDonationDate;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1; // nulls last
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });
          break;
        case 'high_donations':
          donorsWithDistance.sort((a, b) {
            final aCount = donationCounts[a.donor.id] ?? 0;
            final bCount = donationCounts[b.donor.id] ?? 0;
            return bCount.compareTo(aCount); // Higher count first
          });
          break;
      }

      return donorsWithDistance.map((d) => d.donor).toList();
    } catch (e, stack) {
      _logger.error('Failed to find nearby donors', error: e, stackTrace: stack);
      rethrow;
    }
  }
}

/// Internal helper to pair a donor with their calculated distance.
class _DonorWithDistance {
  final UserProfile donor;
  final double distanceKm;

  const _DonorWithDistance({required this.donor, required this.distanceKm});
}
