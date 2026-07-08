class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);
}

class DatabaseException extends AppException {
  const DatabaseException([super.message = 'Database error occurred']);
}

class AuthenticationException extends AppException {
  const AuthenticationException([super.message = 'Authentication failed']);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized access']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Resource not found']);
}

class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException(super.message, {this.errors});
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

class LocationDisabledException extends AppException {
  const LocationDisabledException([
    super.message = 'Location services are disabled. Please enable them in settings.',
  ]);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(String permission)
      : super('$permission permission denied');
}

class PermissionPermanentlyDeniedException extends AppException {
  const PermissionPermanentlyDeniedException(String permission)
      : super(
          '$permission permission permanently denied. Please enable it in settings.',
        );
}

class LocationServiceException extends AppException {
  const LocationServiceException(super.message);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Storage operation failed']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}

class DonorEligibilityException extends AppException {
  const DonorEligibilityException(super.message);
}
