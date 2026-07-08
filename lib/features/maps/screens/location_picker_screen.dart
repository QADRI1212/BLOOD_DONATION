import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/location_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/custom_appbar.dart';

/// Screen that lets the user pick a location on a map and returns
/// the selected latitude/longitude coordinates.
class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const LocationPickerScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();

  LatLng _selectedLocation = const LatLng(28.6139, 77.2090); // Default: New Delhi
  bool _isLoading = true;
  String? _address;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _mapController.move(_selectedLocation, 15.0);
      setState(() => _isLoading = false);
      _reverseGeocode();
      return;
    }

    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _mapController.move(_selectedLocation, 15.0);
        setState(() => _isLoading = false);
        _reverseGeocode();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _reverseGeocode() async {
    final addr = await _locationService.getAddressFromLatLng(
      _selectedLocation.latitude,
      _selectedLocation.longitude,
    );
    if (mounted) setState(() => _address = addr);
  }

  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _selectedLocation = point;
    });
    // Don't re-center the map — let the user pan freely.
    // The marker will appear at the tapped location automatically.
    _reverseGeocode();
  }

  void _confirmLocation() {
    Navigator.of(context).pop({
      'latitude': _selectedLocation.latitude,
      'longitude': _selectedLocation.longitude,
      'address': _address ?? 'Selected Location',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Pick Location',
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded),
            onPressed: _initLocation,
            tooltip: 'My Location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 15.0,
                    onTap: _onMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.blood_donation',
                    ),
                    // Draggable-style marker at center
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: AppColors.primary,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Crosshair hint at top
                Positioned(
                  top: 8,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app_rounded, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap anywhere on the map to place a marker',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.grey600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom card with coordinates
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Coordinates display
                        Row(
                          children: [
                            Expanded(
                              child: _CoordField(
                                label: 'Latitude',
                                value: _selectedLocation.latitude.toStringAsFixed(6),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _CoordField(
                                label: 'Longitude',
                                value: _selectedLocation.longitude.toStringAsFixed(6),
                              ),
                            ),
                          ],
                        ),
                        if (_address != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 16, color: AppColors.grey500),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _address!,
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.grey600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        AppButton(
                          label: 'Confirm Location',
                          onPressed: _confirmLocation,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CoordField extends StatelessWidget {
  final String label;
  final String value;

  const _CoordField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: AppColors.grey500)),
          const SizedBox(height: 2),
          Text(value, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
