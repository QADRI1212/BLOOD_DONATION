/// Donor eligibility calculation utility.
///
/// Implements standard blood donor eligibility criteria:
/// - Age: 18–65 years
/// - Weight: ≥ 50 kg
/// - Donation interval: ≥ 90 days since last donation
/// - Additional: general health check
class DonorEligibility {
  DonorEligibility._();

  /// Minimum age for blood donation
  static const int minAge = 18;

  /// Maximum age for blood donation
  static const int maxAge = 65;

  /// Minimum weight in kg for blood donation
  static const double minWeightKg = 50.0;

  /// Minimum interval between whole blood donations (90 days)
  static const int minDonationIntervalDays = 90;

  /// Check if a donor meets all eligibility criteria.
  ///
  /// Returns an [EligibilityResult] with whether the donor is eligible,
  /// and a list of reasons if they are not.
  static EligibilityResult checkEligibility({
    required int age,
    required double weight,
    DateTime? lastDonationDate,
    bool isHealthy = true,
  }) {
    final issues = <String>[];

    // Age check
    if (age < minAge) {
      issues.add('You must be at least $minAge years old to donate blood.');
    } else if (age > maxAge) {
      issues.add('Donors over $maxAge require physician approval.');
    }

    // Weight check
    if (weight < minWeightKg) {
      issues.add('Minimum weight of ${minWeightKg.toInt()} kg is required.');
    }

    // Health check
    if (!isHealthy) {
      issues.add('You must be in good general health to donate.');
    }

    // Interval check
    if (lastDonationDate != null) {
      final daysSinceLastDonation =
          DateTime.now().difference(lastDonationDate).inDays;
      if (daysSinceLastDonation < minDonationIntervalDays) {
        final remainingDays = minDonationIntervalDays - daysSinceLastDonation;
        issues.add(
          'Please wait $remainingDays more day(s) before your next donation (minimum $minDonationIntervalDays day interval).',
        );
      }
    }

    return EligibilityResult(
      isEligible: issues.isEmpty,
      issues: issues,
    );
  }

  /// Calculate the next eligible donation date.
  static DateTime? calculateNextEligibleDate(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return null;
    return lastDonationDate.add(Duration(days: minDonationIntervalDays));
  }

  /// Get a human-readable status message about eligibility.
  static String getEligibilityMessage({
    required int age,
    required double weight,
    DateTime? lastDonationDate,
    bool isHealthy = true,
  }) {
    final result = checkEligibility(
      age: age,
      weight: weight,
      lastDonationDate: lastDonationDate,
      isHealthy: isHealthy,
    );

    if (result.isEligible) {
      final nextDate = calculateNextEligibleDate(lastDonationDate);
      if (nextDate != null) {
        final formatted = '${nextDate.day}/${nextDate.month}/${nextDate.year}';
        return 'Eligible to donate (next eligible: $formatted)';
      }
      return 'Eligible to donate now';
    }

    return result.issues.first;
  }

  /// Calculate the number of days since the last donation.
  static int? daysSinceLastDonation(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return null;
    return DateTime.now().difference(lastDonationDate).inDays;
  }

  /// Calculate the number of days until the next eligible donation date.
  static int? daysUntilNextEligible(DateTime? lastDonationDate) {
    if (lastDonationDate == null) return null;
    final nextDate = calculateNextEligibleDate(lastDonationDate);
    if (nextDate == null) return null;
    final days = nextDate.difference(DateTime.now()).inDays;
    return days > 0 ? days : 0;
  }
}

/// Result of an eligibility check.
class EligibilityResult {
  /// Whether the donor is eligible to donate.
  final bool isEligible;

  /// List of issues preventing donation (empty if eligible).
  final List<String> issues;

  const EligibilityResult({
    required this.isEligible,
    this.issues = const [],
  });

  /// A summary string of all issues.
  String get summary => issues.join('\n');
}
