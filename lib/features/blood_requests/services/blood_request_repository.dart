import '../../../shared/models/blood_request.dart';

abstract class BloodRequestRepository {
  Future<List<BloodRequest>> getRequests({
    String? status,
    String? patientId,
    String? donorId,
    int? limit,
    int? offset,
  });

  Future<BloodRequest?> getRequestById(String id);

  Future<BloodRequest> createRequest(BloodRequest request);

  Future<BloodRequest> updateRequestStatus(
    String requestId,
    String status, {
    String? donorId,
    String? donorName,
  });

  Future<void> cancelRequest(String requestId);

  Stream<List<BloodRequest>> subscribeToNewRequests({
    String? bloodGroup,
    double? latitude,
    double? longitude,
    double radiusKm,
  });
}
