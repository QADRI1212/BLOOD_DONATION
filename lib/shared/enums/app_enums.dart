enum UserRole {
  donor,
  patient,
  hospital,
  admin;

  String get displayName => name.toUpperCase();

  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (r) => r.name == role.toLowerCase(),
      orElse: () => UserRole.donor,
    );
  }
}

enum BloodGroup {
  aPositive('A+'),
  aNegative('A-'),
  bPositive('B+'),
  bNegative('B-'),
  abPositive('AB+'),
  abNegative('AB-'),
  oPositive('O+'),
  oNegative('O-');

  final String displayName;
  const BloodGroup(this.displayName);

  static BloodGroup fromString(String value) {
    return BloodGroup.values.firstWhere(
      (bg) => bg.displayName == value.toUpperCase(),
      orElse: () => BloodGroup.oPositive,
    );
  }
}

enum RequestStatus {
  pending,
  accepted,
  completed,
  cancelled,
  closed;

  String get displayName => name.toUpperCase();

  static RequestStatus fromString(String status) {
    return RequestStatus.values.firstWhere(
      (s) => s.name == status.toLowerCase(),
      orElse: () => RequestStatus.pending,
    );
  }
}

enum EmergencyLevel {
  critical,
  urgent,
  normal;

  String get displayName => name.toUpperCase();

  static EmergencyLevel fromString(String level) {
    return EmergencyLevel.values.firstWhere(
      (l) => l.name == level.toLowerCase(),
      orElse: () => EmergencyLevel.normal,
    );
  }
}

enum NotificationType {
  emergency,
  reminder,
  general,
  announcement;

  String get displayName => name.toUpperCase();

  static NotificationType fromString(String type) {
    return NotificationType.values.firstWhere(
      (t) => t.name == type.toLowerCase(),
      orElse: () => NotificationType.general,
    );
  }
}

enum Gender {
  male,
  female,
  other;

  String get displayName => name.toUpperCase();

  static Gender fromString(String gender) {
    return Gender.values.firstWhere(
      (g) => g.name == gender.toLowerCase(),
      orElse: () => Gender.other,
    );
  }
}

enum ThemeModePreference {
  light,
  dark,
  system;

  String get displayName => name.toUpperCase();

  static ThemeModePreference fromString(String mode) {
    return ThemeModePreference.values.firstWhere(
      (m) => m.name == mode.toLowerCase(),
      orElse: () => ThemeModePreference.system,
    );
  }
}
