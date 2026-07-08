import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/supabase_client.dart';
import '../../../core/services/logger_service.dart';
import '../../../shared/models/blood_request.dart';
import './blood_request_repository.dart';

class BloodRequestRepositoryImpl implements BloodRequestRepository {
  final ApiService _api;
  final SupabaseClientService _supabase;
  final LoggerService _logger = LoggerService();

  RealtimeChannel? _channel;

  BloodRequestRepositoryImpl(this._api, this._supabase);

  @override
  Future<List<BloodRequest>> getRequests({
    String? status,
    String? patientId,
    String? donorId,
    int? limit,
    int? offset,
  }) async {
    final filters = <String, dynamic>{};
    if (status != null) filters['status'] = status;
    if (patientId != null) filters['patient_id'] = patientId;
    if (donorId != null) filters['donor_id'] = donorId;

    final data = await _api.query(
      'blood_requests',
      filters: filters.isNotEmpty ? filters : null,
      orderBy: 'created_at',
      ascending: false,
      limit: limit,
      offset: offset,
    );
    return data.map((e) => BloodRequest.fromJson(e)).toList();
  }

  @override
  Future<BloodRequest?> getRequestById(String id) async {
    final data = await _api.querySingle('blood_requests', 'id', id);
    if (data == null) return null;
    return BloodRequest.fromJson(data);
  }

  @override
  Future<BloodRequest> createRequest(BloodRequest request) async {
    final data = await _api.insert('blood_requests', request.toJson());
    return BloodRequest.fromJson(data);
  }

  @override
  Future<BloodRequest> updateRequestStatus(
    String requestId,
    String status, {
    String? donorId,
    String? donorName,
  }) async {
    final updates = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (donorId != null) updates['donor_id'] = donorId;
    if (donorName != null) updates['donor_name'] = donorName;

    await _api.update('blood_requests', updates, 'id', requestId);
    final data = await _api.querySingle('blood_requests', 'id', requestId);
    return BloodRequest.fromJson(data!);
  }

  @override
  Future<void> cancelRequest(String requestId) async {
    await _api.update(
      'blood_requests',
      {'status': 'cancelled', 'updated_at': DateTime.now().toIso8601String()},
      'id',
      requestId,
    );
  }

  @override
  Stream<List<BloodRequest>> subscribeToNewRequests({
    String? bloodGroup,
    double? latitude,
    double? longitude,
    double radiusKm = 25,
  }) {
    // Unsubscribe any previous channel before creating a new one
    _channel?.unsubscribe();
    _channel = null;

    final channel = _supabase.client.channel('public:blood_requests');
    _channel = channel;

    final controller = StreamController<List<BloodRequest>>.broadcast(
      onCancel: () {
        channel.unsubscribe();
        if (_channel == channel) _channel = null;
      },
    );

    try {
      // Listen for new blood requests (INSERT)
      channel.onPostgresChanges(
        table: 'blood_requests',
        schema: 'public',
        event: PostgresChangeEvent.insert,
        callback: (payload) {
          try {
            final record = Map<String, dynamic>.from(
              payload.newRecord as Map,
            );
            final request = BloodRequest.fromJson(record);

            // Optionally filter by blood group
            if (bloodGroup != null && request.bloodGroup != bloodGroup) {
              return;
            }

            controller.add([request]);
          } catch (e, stack) {
            _logger.error('Failed to parse realtime blood request', error: e, stackTrace: stack);
          }
        },
      );

      // Listen for status changes (UPDATE) on blood requests
      channel.onPostgresChanges(
        table: 'blood_requests',
        schema: 'public',
        event: PostgresChangeEvent.update,
        callback: (payload) {
          try {
            final record = Map<String, dynamic>.from(
              payload.newRecord as Map,
            );
            final request = BloodRequest.fromJson(record);
            controller.add([request]);
          } catch (e, stack) {
            _logger.error('Failed to parse updated blood request', error: e, stackTrace: stack);
          }
        },
      );

      channel.subscribe();
    } catch (e, stack) {
      _logger.error('Failed to subscribe to blood_requests', error: e, stackTrace: stack);
      // Stream will just not emit — consumer handles gracefully
    }

    return controller.stream;
  }
}
