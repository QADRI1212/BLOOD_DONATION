import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  final bool success;
  final String? message;
  final String? userId;
  final bool emailVerified;

  const AuthResponse({
    required this.success,
    this.message,
    this.userId,
    this.emailVerified = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> map) {
    return AuthResponse(
      success: map['success'] as bool? ?? true,
      message: map['message'] as String?,
      userId: map['user_id'] as String?,
      emailVerified: map['email_verified'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [success, message, userId, emailVerified];
}
