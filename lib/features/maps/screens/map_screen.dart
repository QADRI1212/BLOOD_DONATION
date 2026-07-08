import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../services/maps_repository.dart';
import '../providers/maps_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  LatLng? _currentPosition;
  bool _isLoading = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _isLoading = false;
        });
        _mapController.move(_currentPosition!, 13.0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentPosition = const LatLng(28.6139, 77.2090);
          _isLoading = false;
          _locationError = 'Could not get precise location';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userId = authState.valueOrNull?.id;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Map View',
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _centerOnCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Getting your location...')
          : Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition ?? const LatLng(28.6139, 77.2090),
                    initialZoom: 13.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.blood_donation',
                    ),
                    // Marker layer with data from provider
                    _MarkersLayer(
                      currentPosition: _currentPosition,
                      userId: userId,
                    ),
                  ],
                ),
                // Legend
                Positioned(
                  left: 16,
                  bottom: 24,
                  child: _buildLegend(),
                ),
                // Error banner
                if (_locationError != null)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: AppColors.warning.withValues(alpha: 0.9),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          Text(_locationError!, style: const TextStyle(color: Colors.white, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Legend', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _LegendItem(color: AppColors.success, label: 'Donor'),
          const SizedBox(height: 4),
          _LegendItem(color: AppColors.primary, label: 'Hospital'),
          const SizedBox(height: 4),
          _LegendItem(color: AppColors.secondary, label: 'Blood Bank'),
          const SizedBox(height: 4),
          _LegendItem(color: AppColors.warning, label: 'Emergency'),
        ],
      ),
    );
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15.0);
    }
  }
}

class _MarkersLayer extends ConsumerWidget {
  final LatLng? currentPosition;
  final String? userId;

  const _MarkersLayer({this.currentPosition, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (currentPosition == null) return const SizedBox.shrink();

    final markersAsync = ref.watch(mapMarkersProvider(
      MapMarkerQueryParams(
        latitude: currentPosition!.latitude,
        longitude: currentPosition!.longitude,
        radiusKm: 25,
      ),
    ));

    final markers = <Marker>[];

    // Current position marker
    if (currentPosition != null) {
      markers.add(Marker(
        point: currentPosition!,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
        ),
      ));
    }

    // Data markers from provider
    markersAsync.whenData((mapMarkers) {
      for (final marker in mapMarkers) {
        markers.add(Marker(
          point: LatLng(marker.latitude, marker.longitude),
          width: 36,
          height: 36,
          child: _buildMarkerIcon(marker),
        ));
      }
    });

    return MarkerLayer(markers: markers);
  }

  Widget _buildMarkerIcon(MapMarker marker) {
    Color markerColor;
    IconData markerIcon;

    switch (marker.type) {
      case 'donor':
        markerColor = AppColors.success;
        markerIcon = Icons.bloodtype_rounded;
        break;
      case 'hospital':
        markerColor = AppColors.primary;
        markerIcon = Icons.local_hospital_rounded;
        break;
      case 'blood_bank':
        markerColor = AppColors.secondary;
        markerIcon = Icons.bloodtype_rounded;
        break;
      case 'request':
        markerColor = AppColors.warning;
        markerIcon = Icons.emergency_rounded;
        break;
      default:
        markerColor = AppColors.grey500;
        markerIcon = Icons.location_on_rounded;
    }

    return Container(
      decoration: BoxDecoration(
        color: markerColor,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(markerIcon, color: Colors.white, size: 18),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTypography.labelSmall),
      ],
    );
  }
}
