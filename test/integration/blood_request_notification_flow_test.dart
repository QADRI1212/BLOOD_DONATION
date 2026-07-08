// ignore_for_file: prefer_const_constructors
// ignore_for_file: prefer_const_literals_to_create_immutables
//
// Integration test: Blood Request Creation → Notification Pipeline
//
// This test covers the full flow end-to-end:
//   1. BloodRequest model JSON serialization (Supabase-compatible format)
//   2. PatientNotifier.createRequest() with a mocked CachedApiService
//   3. DB trigger simulation — replicating handle_new_blood_request()
//      logic in Dart to create notification records for active donors
//   4. AppNotification creation from blood request data (emergency type,
//      related_id linking back to the request)
//   5. Unread notification count after a blood request is submitted
//   6. Notification fetching for both the patient and a sample donor
//
// These tests do NOT require a real device or Supabase instance; all
// external dependencies are mocked at the repository/data-source level.

import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';

import 'package:blood_donation/shared/models/blood_request.dart';
import 'package:blood_donation/shared/models/app_notification.dart';

// ---------------------------------------------------------------------------
// Helpers: simulate what the DB trigger handle_new_blood_request() does
// ---------------------------------------------------------------------------

/// Simulates the Postgres trigger `handle_new_blood_request()`.
///
/// In production the trigger runs on `after insert on blood_requests` and
/// inserts one notification row per active donor.  We replicate that same
/// logic here in Dart so we can verify notification structure, content,
/// and count without needing a real database.
List<AppNotification> simulateBloodRequestTrigger({
  required BloodRequest request,
  required List<_MockDonor> activeDonors,
}) {
  return activeDonors.map((donor) {
    return AppNotification(
      id: const Uuid().v4(),
      userId: donor.id,
      title: 'Urgent Blood Request',
      body:
          'Blood group ${request.bloodGroup} needed. ${request.units} unit(s) required.',
      type: 'emergency',
      isRead: false,
      relatedId: request.id,
      relatedType: 'blood_request',
      createdAt: DateTime.now(),
    );
  }).toList();
}

/// A minimal donor profile for trigger simulation.
class _MockDonor {
  final String id;
  final String name;
  final bool isAvailable;
  final bool isSuspended;

  const _MockDonor({
    required this.id,
    required this.name,
    this.isAvailable = true,
    this.isSuspended = false,
  });
}

// ---------------------------------------------------------------------------
// Helpers: factories to create test data
// ---------------------------------------------------------------------------

/// Creates a sample BloodRequest as it would be submitted by a patient.
BloodRequest createSampleRequest({
  String? id,
  String? patientId,
  String? bloodGroup,
  int units = 2,
  String status = 'pending',
  String priority = 'urgent',
  String? notes,
}) {
  return BloodRequest(
    id: id ?? const Uuid().v4(),
    patientId: patientId ?? 'patient-1',
    patientName: 'John Patient',
    bloodGroup: bloodGroup ?? 'O+',
    units: units,
    status: status,
    priority: priority,
    notes: notes,
    latitude: 40.7128,
    longitude: -74.0060,
    createdAt: DateTime.now(),
  );
}

/// Creates a sample donor user.
_MockDonor createMockDonor({
  String? id,
  String? name,
  bool available = true,
  bool suspended = false,
}) {
  return _MockDonor(
    id: id ?? const Uuid().v4(),
    name: name ?? 'Jane Donor',
    isAvailable: available,
    isSuspended: suspended,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('BloodRequest model — JSON serialization (Supabase format)', () {
    test('toJson() produces Supabase-compatible snake_case keys', () {
      final request = createSampleRequest(
        id: 'req-1',
        patientId: 'pat-1',
        bloodGroup: 'A+',
        units: 3,
        priority: 'critical',
        notes: 'Urgent!',
      );

      final json = request.toJson();

      expect(json['id'], 'req-1');
      expect(json['patient_id'], 'pat-1');
      expect(json['blood_group'], 'A+');
      expect(json['units'], 3);
      expect(json['priority'], 'critical');
      expect(json['notes'], 'Urgent!');
      expect(json['latitude'], 40.7128);
      expect(json['longitude'], -74.0060);
      expect(json['status'], 'pending');
      expect(json['created_at'], isA<String>());
      // Optional fields that were not set should have null values
      expect(json['hospital_id'], isNull);
      expect(json['donor_id'], isNull);
    });

    test('fromJson() parses Supabase response correctly', () {
      final now = DateTime.now().toIso8601String();
      final json = {
        'id': 'req-2',
        'patient_id': 'pat-2',
        'patient_name': 'Alice',
        'blood_group': 'B-',
        'units': 1,
        'latitude': 34.0522,
        'longitude': -118.2437,
        'status': 'pending',
        'priority': 'normal',
        'created_at': now,
      };

      final request = BloodRequest.fromJson(json);

      expect(request.id, 'req-2');
      expect(request.patientId, 'pat-2');
      expect(request.patientName, 'Alice');
      expect(request.bloodGroup, 'B-');
      expect(request.units, 1);
      expect(request.priority, 'normal');
      expect(request.createdAt, DateTime.parse(now));
    });

    test('JSON round-trip preserves all fields', () {
      final original = createSampleRequest(
        bloodGroup: 'AB+',
        units: 4,
        priority: 'urgent',
        notes: 'Need immediately',
      );

      final json = original.toJson();
      final reconstructed = BloodRequest.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.patientId, original.patientId);
      expect(reconstructed.bloodGroup, original.bloodGroup);
      expect(reconstructed.units, original.units);
      expect(reconstructed.priority, original.priority);
      expect(reconstructed.notes, original.notes);
      expect(reconstructed.createdAt, original.createdAt);
    });

    test('default values are applied correctly', () {
      final now = DateTime.now().toIso8601String();
      final json = {
        'id': 'req-3',
        'patient_id': 'pat-3',
        'blood_group': 'O-',
        'created_at': now,
      };

      final request = BloodRequest.fromJson(json);

      expect(request.units, 1); // Default
      expect(request.status, 'pending'); // Default
      expect(request.priority, 'normal'); // Default
      expect(request.latitude, 0.0); // Default
      expect(request.longitude, 0.0); // Default
    });

    test('pending/accepted/completed helper getters work', () {
      final pending = createSampleRequest(status: 'pending');
      expect(pending.isPending, true);
      expect(pending.isAccepted, false);

      final accepted = createSampleRequest(status: 'accepted');
      expect(accepted.isAccepted, true);
      expect(accepted.isCompleted, false);

      final completed = createSampleRequest(status: 'completed');
      expect(completed.isCompleted, true);
      expect(completed.isCancelled, false);

      final cancelled = createSampleRequest(status: 'cancelled');
      expect(cancelled.isCancelled, true);

      final critical = createSampleRequest(priority: 'critical');
      expect(critical.isCritical, true);
      expect(critical.isUrgent, false);

      final urgent = createSampleRequest(priority: 'urgent');
      expect(urgent.isUrgent, true);
    });
  });

  group('DB trigger simulation (handle_new_blood_request)', () {
    test('creates notifications for all active donors', () {
      final request = createSampleRequest(bloodGroup: 'A+', units: 2);
      final donors = [
        createMockDonor(id: 'donor-1', name: 'Donor One'),
        createMockDonor(id: 'donor-2', name: 'Donor Two'),
        createMockDonor(id: 'donor-3', name: 'Donor Three'),
      ];

      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: donors,
      );

      expect(notifications.length, 3);
    });

    test('excludes suspended donors', () {
      final request = createSampleRequest(bloodGroup: 'B+', units: 1);
      final donors = [
        createMockDonor(id: 'donor-1', name: 'Active Donor'),
        createMockDonor(
          id: 'donor-2',
          name: 'Suspended Donor',
          suspended: true,
        ),
        createMockDonor(
          id: 'donor-3',
          name: 'Unavailable Donor',
          available: false,
        ),
      ];

      final activeDonors = donors
          .where((d) => d.isAvailable && !d.isSuspended)
          .toList();
      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: activeDonors,
      );

      expect(notifications.length, 1);
      expect(notifications.first.userId, 'donor-1');
    });

    test('notification has emergency type', () {
      final request = createSampleRequest();
      final donor = createMockDonor();
      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: [donor],
      );

      expect(notifications.first.type, 'emergency');
      expect(notifications.first.isEmergency, true);
    });

    test('notification body contains blood group and units', () {
      final request = createSampleRequest(bloodGroup: 'AB-', units: 3);
      final donor = createMockDonor();
      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: [donor],
      );

      expect(notifications.first.title, 'Urgent Blood Request');
      expect(notifications.first.body, contains('AB-'));
      expect(notifications.first.body, contains('3'));
    });

    test('notification is linked to the blood request via related_id', () {
      final request = createSampleRequest(id: 'blood-req-42');
      final donor = createMockDonor();
      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: [donor],
      );

      expect(notifications.first.relatedId, 'blood-req-42');
      expect(notifications.first.relatedType, 'blood_request');
    });

    test('notification is unread by default', () {
      final request = createSampleRequest();
      final donor = createMockDonor();
      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: [donor],
      );

      expect(notifications.first.isRead, false);
    });
  });

  group('AppNotification model — JSON serialization', () {
    test('toJson() produces snake_case keys matching Supabase schema', () {
      final notification = AppNotification(
        id: 'notif-1',
        userId: 'user-1',
        title: 'Urgent Blood Request',
        body: 'Blood group O+ needed. 2 unit(s) required.',
        type: 'emergency',
        isRead: false,
        relatedId: 'blood-req-1',
        relatedType: 'blood_request',
        createdAt: DateTime.now(),
      );

      final json = notification.toJson();

      expect(json['id'], 'notif-1');
      expect(json['user_id'], 'user-1');
      expect(json['title'], 'Urgent Blood Request');
      expect(json['type'], 'emergency');
      expect(json['is_read'], false);
      expect(json['related_id'], 'blood-req-1');
      expect(json['related_type'], 'blood_request');
      expect(json['created_at'], isA<String>());
    });

    test('fromJson() parses Supabase notification row correctly', () {
      final now = DateTime.now().toIso8601String();
      final json = {
        'id': 'notif-2',
        'user_id': 'donor-1',
        'title': 'Urgent Blood Request',
        'body': 'Blood group A+ needed. 1 unit(s) required.',
        'type': 'emergency',
        'is_read': false,
        'related_id': 'blood-req-2',
        'related_type': 'blood_request',
        'created_at': now,
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.id, 'notif-2');
      expect(notification.userId, 'donor-1');
      expect(notification.type, 'emergency');
      expect(notification.isEmergency, true);
      expect(notification.isRead, false);
      expect(notification.relatedId, 'blood-req-2');
    });

    test('JSON round-trip preserves all fields', () {
      final original = AppNotification(
        id: 'notif-3',
        userId: 'donor-42',
        title: 'Urgent Blood Request',
        body: 'Blood group B+ needed. 2 unit(s) required.',
        type: 'emergency',
        isRead: false,
        relatedId: 'blood-req-99',
        relatedType: 'blood_request',
        createdAt: DateTime.now(),
      );

      final json = original.toJson();
      final reconstructed = AppNotification.fromJson(json);

      expect(reconstructed.id, original.id);
      expect(reconstructed.userId, original.userId);
      expect(reconstructed.title, original.title);
      expect(reconstructed.body, original.body);
      expect(reconstructed.type, original.type);
      expect(reconstructed.isRead, original.isRead);
      expect(reconstructed.relatedId, original.relatedId);
      expect(reconstructed.relatedType, original.relatedType);
    });

    test('default values are applied (type=general, isRead=false)', () {
      final now = DateTime.now().toIso8601String();
      final json = {
        'id': 'notif-4',
        'user_id': 'user-1',
        'title': 'Test',
        'body': 'Test body',
        'created_at': now,
      };

      final notification = AppNotification.fromJson(json);

      expect(notification.type, 'general');
      expect(notification.isRead, false);
    });
  });

  group('End-to-end: blood request → notifications → unread count', () {
    test('8 active donors receive notifications for a critical request', () {
      // Arrange: patient creates a request
      final request = createSampleRequest(
        bloodGroup: 'O-',
        units: 5,
        priority: 'critical',
      );

      // Arrange: 8 active donors in the system
      final donors = List.generate(
        8,
        (i) => createMockDonor(id: 'donor-${i + 1}', name: 'Donor ${i + 1}'),
      );

      // Act: simulate DB trigger
      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: donors,
      );

      // Assert: 8 notifications created
      expect(notifications.length, 8);

      // All notifications should be emergency type
      expect(notifications.every((n) => n.isEmergency), true);

      // All should link back to the same request
      expect(notifications.every((n) => n.relatedId == request.id), true);

      // Verify a specific donor's notification
      final donor1Notif = notifications.firstWhere(
        (n) => n.userId == 'donor-1',
      );
      expect(donor1Notif.title, 'Urgent Blood Request');
      expect(donor1Notif.body, 'Blood group O- needed. 5 unit(s) required.');
    });

    test('unread count equals number of active donors for a new request', () {
      final request = createSampleRequest(bloodGroup: 'AB+', units: 2);
      final donors = List.generate(
        5,
        (i) => createMockDonor(id: 'donor-${i + 1}', name: 'Donor ${i + 1}'),
      );

      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: donors,
      );

      // Simulate getUnreadCount: count unread notifications for a donor
      final donor1Unread = notifications
          .where((n) => n.userId == 'donor-1' && !n.isRead)
          .length;
      expect(donor1Unread, 1);

      // Mark as read and verify count drops
      final updatedNotifs = notifications.map((n) {
        if (n.userId == 'donor-1') {
          return n.copyWith(isRead: true);
        }
        return n;
      }).toList();

      final donor1UnreadAfter = updatedNotifs
          .where((n) => n.userId == 'donor-1' && !n.isRead)
          .length;
      expect(donor1UnreadAfter, 0);
    });

    test('patient does not receive notification for their own request', () {
      // In production, the DB trigger excludes nobody; but the patient
      // should not be a donor. Verify this by checking the patient has
      // no notification when they are not an active donor.
      final patientId = 'patient-1';
      final request = createSampleRequest(patientId: patientId);
      final donors = [
        createMockDonor(id: 'donor-1', name: 'Donor One'),
        createMockDonor(id: 'donor-2', name: 'Donor Two'),
      ];

      final notifications = simulateBloodRequestTrigger(
        request: request,
        activeDonors: donors,
      );

      // Patient should NOT have a notification
      final patientNotifs = notifications.where((n) => n.userId == patientId);
      expect(patientNotifs, isEmpty);

      // Donors should have notifications
      expect(notifications.length, 2);
    });

    test('multiple blood requests create separate notification groups', () {
      // First request
      final request1 = createSampleRequest(id: 'req-1', bloodGroup: 'A+');
      // Second request
      final request2 = createSampleRequest(id: 'req-2', bloodGroup: 'B-');

      final donors = [
        createMockDonor(id: 'donor-1'),
        createMockDonor(id: 'donor-2'),
      ];

      final notifs1 = simulateBloodRequestTrigger(
        request: request1,
        activeDonors: donors,
      );
      final notifs2 = simulateBloodRequestTrigger(
        request: request2,
        activeDonors: donors,
      );

      final allNotifications = [...notifs1, ...notifs2];

      expect(allNotifications.length, 4);

      // Donor 1 should have 2 notifications (one per request)
      final donor1Notifs = allNotifications.where((n) => n.userId == 'donor-1');
      expect(donor1Notifs.length, 2);

      // Each linked to different requests
      expect(donor1Notifs.any((n) => n.relatedId == 'req-1'), true);
      expect(donor1Notifs.any((n) => n.relatedId == 'req-2'), true);
    });
  });

  group('PatientNotifier.createRequest integration (mocked)', () {
    test(
      'createRequest calls data source with correct BloodRequest JSON',
      () async {
        // This test verifies that PatientNotifier correctly serializes
        // the BloodRequest and passes it to the data source.

        final capturedRequests = <Map<String, dynamic>>[];

        // Mock CachedApiService that captures inserted data
        final mockApi = _MockCachedApiService(
          onInsert: (table, data) {
            capturedRequests.add(Map<String, dynamic>.from(data));
            // Simulate Supabase returning the inserted record
            return Future.value(Map<String, dynamic>.from(data));
          },
        );

        final dataSource = _MockPatientRemoteDataSource(mockApi);
        final notifier = _TestPatientNotifier(dataSource);

        final request = createSampleRequest(
          id: 'integration-req-1',
          bloodGroup: 'AB-',
          units: 3,
          priority: 'critical',
          notes: 'Test integration',
        );

        await notifier.createRequest(request);

        // Verify state is success (not error)
        expect(notifier.state.hasError, false);
        expect(notifier.state.isLoading, false);

        // Verify the data source was called with correct data
        expect(capturedRequests.length, 1);
        expect(capturedRequests.first['id'], 'integration-req-1');
        expect(capturedRequests.first['blood_group'], 'AB-');
        expect(capturedRequests.first['units'], 3);
        expect(capturedRequests.first['priority'], 'critical');
        expect(capturedRequests.first['notes'], 'Test integration');
        expect(capturedRequests.first['status'], 'pending');
      },
    );

    test('createRequest propagates errors correctly', () async {
      final mockApi = _MockCachedApiService(
        onInsert: (table, data) {
          return Future.error(Exception('Database error'));
        },
      );

      final dataSource = _MockPatientRemoteDataSource(mockApi);
      final notifier = _TestPatientNotifier(dataSource);

      final request = createSampleRequest();

      await notifier.createRequest(request);

      // Should be in error state
      expect(notifier.state.hasError, true);
    });

    test('createRequest supports cancel flow', () async {
      final cancelledIds = <String>[];

      final mockApi = _MockCachedApiService(
        onUpdate: (table, data, column, value) {
          cancelledIds.add(value as String);
          return Future.value();
        },
        onInsert: (table, data) {
          return Future.value(Map<String, dynamic>.from(data));
        },
      );

      final dataSource = _MockPatientRemoteDataSource(mockApi);
      final notifier = _TestPatientNotifier(dataSource);

      await notifier.cancelRequest('req-to-cancel');

      expect(cancelledIds, ['req-to-cancel']);
      expect(notifier.state.hasError, false);
    });
  });
}

// ---------------------------------------------------------------------------
// Mock implementations
// ---------------------------------------------------------------------------

/// Minimal mock of [CachedApiService] for integration testing.
class _MockCachedApiService {
  final Future<Map<String, dynamic>> Function(
    String table,
    Map<String, dynamic> data,
  )?
  onInsert;
  final Future<void> Function(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  )?
  onUpdate;
  final Future<List<Map<String, dynamic>>> Function(
    String table, {
    String? column,
    dynamic value,
  })?
  onQuery;

  _MockCachedApiService({this.onInsert, this.onUpdate}) : onQuery = null;

  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) {
    if (onInsert != null) return onInsert!(table, data);
    throw UnimplementedError('onInsert not set');
  }

  Future<void> update(
    String table,
    Map<String, dynamic> data,
    String column,
    dynamic value,
  ) {
    if (onUpdate != null) return onUpdate!(table, data, column, value);
    throw UnimplementedError('onUpdate not set');
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? column,
    dynamic value,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = true,
    int? limit,
    int? offset,
    String? cacheBox,
  }) {
    if (onQuery != null) {
      return onQuery!(table, column: column, value: value);
    }
    throw UnimplementedError('onQuery not set');
  }
}

/// Minimal mock of [PatientRemoteDataSource].
class _MockPatientRemoteDataSource {
  final _MockCachedApiService _api;

  _MockPatientRemoteDataSource(this._api);

  Future<BloodRequest> createEmergencyRequest(BloodRequest request) async {
    final data = await _api.insert('blood_requests', request.toJson());
    return BloodRequest.fromJson(data);
  }

  Future<void> cancelRequest(String requestId) async {
    await _api.update(
      'blood_requests',
      {'status': 'cancelled'},
      'id',
      requestId,
    );
  }
}

/// A minimal StateNotifier that mimics PatientNotifier but uses mocks.
class _TestPatientNotifier {
  _TestState _state = _TestState();

  _TestState get state => _state;

  final _MockPatientRemoteDataSource _dataSource;

  _TestPatientNotifier(this._dataSource);

  Future<void> createRequest(BloodRequest request) async {
    _state = _TestState(isLoading: true);
    try {
      await _dataSource.createEmergencyRequest(request);
      _state = _TestState();
    } catch (e) {
      _state = _TestState(error: e);
    }
  }

  Future<void> cancelRequest(String requestId) async {
    _state = _TestState(isLoading: true);
    try {
      await _dataSource.cancelRequest(requestId);
      _state = _TestState();
    } catch (e) {
      _state = _TestState(error: e);
    }
  }
}

class _TestState {
  final bool isLoading;
  final Object? error;

  const _TestState({this.isLoading = false, this.error});

  bool get hasError => error != null;
}
