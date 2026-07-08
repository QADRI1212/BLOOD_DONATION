import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:geocoding/geocoding.dart';
import '../errors/app_exceptions.dart' as app_exceptions;
import 'logger_service.dart';

class LocationService {
  final LoggerService _logger = LoggerService();

  Future<geolocator.Position> getCurrentPosition() async {
    try {
      bool isLocationEnabled = await geolocator.Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        throw app_exceptions.LocationDisabledException();
      }

      geolocator.LocationPermission permission = await geolocator.Geolocator.checkPermission();
      if (permission == geolocator.LocationPermission.denied) {
        permission = await geolocator.Geolocator.requestPermission();
        if (permission == geolocator.LocationPermission.denied) {
          throw app_exceptions.PermissionDeniedException('Location');
        }
      }

      if (permission == geolocator.LocationPermission.deniedForever) {
        throw app_exceptions.PermissionPermanentlyDeniedException('Location');
      }

      geolocator.Position position = await geolocator.Geolocator.getCurrentPosition(
        locationSettings: const geolocator.LocationSettings(
          accuracy: geolocator.LocationAccuracy.high,
          distanceFilter: 100,
        ),
      );

      return position;
    } on app_exceptions.LocationDisabledException {
      rethrow;
    } on app_exceptions.PermissionDeniedException {
      rethrow;
    } on app_exceptions.PermissionPermanentlyDeniedException {
      rethrow;
    } catch (e, stack) {
      _logger.error('Failed to get current position', error: e, stackTrace: stack);
      throw app_exceptions.LocationServiceException('Failed to get current location: $e');
    }
  }

  Future<String> getAddressFromLatLng(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        return '${place.locality ?? place.subAdministrativeArea ?? ''}, '
            '${place.administrativeArea ?? ''} ${place.country ?? ''}'
            .trim();
      }
      return 'Unknown Location';
    } catch (e, stack) {
      _logger.error('Failed to get address', error: e, stackTrace: stack);
      return 'Unknown Location';
    }
  }

  Future<double> calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) async {
    return geolocator.Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  Stream<geolocator.Position> getPositionStream() {
    return geolocator.Geolocator.getPositionStream(
      locationSettings: const geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
        distanceFilter: 50,
      ),
    );
  }
}
