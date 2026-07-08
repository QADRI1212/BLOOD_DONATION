import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donation/shared/models/hospital.dart';

void main() {
  group('Hospital', () {
    test('creates Hospital with required fields', () {
      final now = DateTime.now();
      final hospital = Hospital(
        id: '123',
        name: 'City Hospital',
        createdAt: now,
      );

      expect(hospital.id, equals('123'));
      expect(hospital.name, equals('City Hospital'));
      expect(hospital.address, isNull);
      expect(hospital.phone, isNull);
      expect(hospital.hours, isNull);
      expect(hospital.verified, isFalse);
      expect(hospital.latitude, equals(0.0));
      expect(hospital.longitude, equals(0.0));
      expect(hospital.distance, isNull);
      expect(hospital.createdAt, equals(now));
    });

    test('creates Hospital with all fields', () {
      final now = DateTime.now();
      final hospital = Hospital(
        id: '456',
        name: 'General Hospital',
        address: '123 Main St, City',
        phone: '+1-555-1234',
        hours: 'Mon-Fri 9AM-5PM',
        latitude: 40.7128,
        longitude: -74.0060,
        verified: true,
        distance: 5.2,
        createdAt: now,
      );

      expect(hospital.address, equals('123 Main St, City'));
      expect(hospital.phone, equals('+1-555-1234'));
      expect(hospital.hours, equals('Mon-Fri 9AM-5PM'));
      expect(hospital.latitude, equals(40.7128));
      expect(hospital.verified, isTrue);
      expect(hospital.distance, equals(5.2));
    });

    test('supports copyWith', () {
      final now = DateTime.now();
      final hospital = Hospital(id: '1', name: 'Old Name', createdAt: now);
      final updated = hospital.copyWith(name: 'New Name', verified: true);

      expect(updated.name, equals('New Name'));
      expect(updated.verified, isTrue);
      expect(updated.id, equals('1')); // unchanged
      expect(updated.createdAt, equals(now)); // unchanged
    });

    test('supports value equality', () {
      final now = DateTime.now();
      final a = Hospital(id: '1', name: 'Test', createdAt: now);
      final b = Hospital(id: '1', name: 'Test', createdAt: now);

      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('supports JSON serialization', () {
      final now = DateTime.parse('2024-01-15T10:30:00Z');
      final hospital = Hospital(
        id: '1',
        name: 'JSON Hospital',
        address: '456 Oak Ave',
        phone: '+1-555-5678',
        hours: '24/7',
        latitude: 34.0522,
        longitude: -118.2437,
        verified: true,
        createdAt: now,
      );

      final json = hospital.toJson();
      expect(json['id'], equals('1'));
      expect(json['name'], equals('JSON Hospital'));
      expect(json['address'], equals('456 Oak Ave'));
      expect(json['latitude'], equals(34.0522));
      expect(json['created_at'], equals('2024-01-15T10:30:00.000Z'));

      final deserialized = Hospital.fromJson(json);
      expect(deserialized, equals(hospital));
    });

    test('handles null address in fromJson', () {
      final json = {
        'id': '1',
        'name': 'No Address',
        'created_at': '2024-01-15T10:30:00.000Z',
      };
      final hospital = Hospital.fromJson(json);
      expect(hospital.name, equals('No Address'));
      expect(hospital.address, isNull);
    });
  });

  group('BloodBank', () {
    test('creates BloodBank with required fields', () {
      final now = DateTime.now();
      final bank = BloodBank(
        id: 'b1',
        name: 'Red Cross Blood Bank',
        createdAt: now,
      );

      expect(bank.id, equals('b1'));
      expect(bank.name, equals('Red Cross Blood Bank'));
      expect(bank.address, isNull);
      expect(bank.phone, isNull);
      expect(bank.verified, isFalse);
      expect(bank.latitude, equals(0.0));
      expect(bank.longitude, equals(0.0));
    });

    test('creates BloodBank with all fields', () {
      final now = DateTime.now();
      final bank = BloodBank(
        id: 'b2',
        name: 'City Blood Center',
        address: '789 Donor Ln',
        phone: '+1-555-9999',
        latitude: 51.5074,
        longitude: -0.1278,
        verified: true,
        distance: 3.1,
        createdAt: now,
      );

      expect(bank.address, equals('789 Donor Ln'));
      expect(bank.phone, equals('+1-555-9999'));
      expect(bank.latitude, equals(51.5074));
      expect(bank.verified, isTrue);
      expect(bank.distance, equals(3.1));
    });

    test('supports copyWith', () {
      final now = DateTime.now();
      final bank = BloodBank(id: '1', name: 'Original', createdAt: now);
      final updated = bank.copyWith(name: 'Updated', verified: true);

      expect(updated.name, equals('Updated'));
      expect(updated.verified, isTrue);
    });

    test('supports JSON round-trip', () {
      final now = DateTime.parse('2024-06-01T12:00:00Z');
      final bank = BloodBank(
        id: 'b3',
        name: 'Plasma Plus',
        address: '321 Health Blvd',
        phone: '+1-555-3333',
        latitude: 35.6762,
        longitude: 139.6503,
        verified: true,
        distance: 7.5,
        createdAt: now,
      );

      final json = bank.toJson();
      final deserialized = BloodBank.fromJson(json);
      expect(deserialized, equals(bank));
    });

    test('generates different equals for different IDs', () {
      final now = DateTime.now();
      final a = BloodBank(id: '1', name: 'Same', createdAt: now);
      final b = BloodBank(id: '2', name: 'Same', createdAt: now);

      expect(a, isNot(equals(b)));
    });
  });
}
