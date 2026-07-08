import './admin_repository.dart';

class AdminStatsDto {
  final int totalUsers;
  final int activeDonors;
  final int totalHospitals;
  final int totalRequests;
  final int pendingRequests;

  const AdminStatsDto({
    this.totalUsers = 0,
    this.activeDonors = 0,
    this.totalHospitals = 0,
    this.totalRequests = 0,
    this.pendingRequests = 0,
  });

  factory AdminStatsDto.fromJson(Map<String, dynamic> map) {
    return AdminStatsDto(
      totalUsers: (map['total_users'] as num?)?.toInt() ?? 0,
      activeDonors: (map['active_donors'] as num?)?.toInt() ?? 0,
      totalHospitals: (map['total_hospitals'] as num?)?.toInt() ?? 0,
      totalRequests: (map['total_requests'] as num?)?.toInt() ?? 0,
      pendingRequests: (map['pending_requests'] as num?)?.toInt() ?? 0,
    );
  }

  AdminStats toDomain() {
    return AdminStats(
      totalUsers: totalUsers,
      activeDonors: activeDonors,
      totalHospitals: totalHospitals,
      totalRequests: totalRequests,
      pendingRequests: pendingRequests,
    );
  }
}
