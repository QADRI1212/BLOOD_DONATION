import './maps_repository.dart';

class MapsUseCases {
  final MapsRepository _repository;

  MapsUseCases(this._repository);

  Future<List<MapMarker>> getNearbyMarkers({
    required double latitude,
    required double longitude,
    double radiusKm = 25,
    List<String>? types,
    String? bloodGroup,
  }) {
    return _repository.getNearbyMarkers(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
      types: types,
      bloodGroup: bloodGroup,
    );
  }
}
