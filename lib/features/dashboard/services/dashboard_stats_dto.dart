import './dashboard_repository.dart';

class DashboardStatsDto {
  final int activeRequests;
  final int totalDonations;
  final int totalUnits;
  final int savedHospitals;
  final int unreadNotifications;

  const DashboardStatsDto({
    this.activeRequests = 0,
    this.totalDonations = 0,
    this.totalUnits = 0,
    this.savedHospitals = 0,
    this.unreadNotifications = 0,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> map) {
    return DashboardStatsDto(
      activeRequests: (map['active_requests'] as num?)?.toInt() ?? 0,
      totalDonations: (map['total_donations'] as num?)?.toInt() ?? 0,
      totalUnits: (map['total_units'] as num?)?.toInt() ?? 0,
      savedHospitals: (map['saved_hospitals'] as num?)?.toInt() ?? 0,
      unreadNotifications: (map['unread_notifications'] as num?)?.toInt() ?? 0,
    );
  }

  DashboardStats toDomain() {
    return DashboardStats(
      activeRequests: activeRequests,
      totalDonations: totalDonations,
      totalUnits: totalUnits,
      savedHospitals: savedHospitals,
      unreadNotifications: unreadNotifications,
    );
  }
}
