import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/localization_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/geometry_utils.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/locale_provider.dart';
import '../../../shared/widgets/donor_card.dart';
import '../../../shared/widgets/donor_map_marker.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/models/user_profile.dart';
import '../providers/nearby_donor_provider.dart';
import '../../../shared/widgets/custom_appbar.dart';

class NearbyDonorsScreen extends ConsumerStatefulWidget {
  const NearbyDonorsScreen({super.key});

  @override
  ConsumerState<NearbyDonorsScreen> createState() => _NearbyDonorsScreenState();
}

class _NearbyDonorsScreenState extends ConsumerState<NearbyDonorsScreen> {
  final LocationService _locationService = LocationService();
  final MapController _mapController = MapController();
  String? _selectedBloodGroup;
  double _distanceKm = 25;
  String _sortBy = 'nearest';
  Position? _currentPosition;
  bool _isLoadingLocation = true;
  bool _hasLocationError = false;
  bool _showMap = false;
  UserProfile? _selectedDonor;
  Timer? _searchDebounce;

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _hasLocationError = false;
    });

    try {
      final position = await _locationService.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        // Fall back to user's profile location
        final user = ref.read(authProvider).valueOrNull;
        if (user?.latitude != null && user?.longitude != null) {
          setState(() {
            _currentPosition = Position(
              latitude: user!.latitude!,
              longitude: user.longitude!,
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
            _isLoadingLocation = false;
          });
        } else {
          setState(() {
            _isLoadingLocation = false;
            _hasLocationError = true;
          });
        }
      }
    }
  }

  Future<void> _callDonor(String phone) async {
    try {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for Android 11+ if manifest isn't updated yet
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not make phone call')),
        );
      }
    }
  }

  void _onFiltersChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {}); // Trigger rebuild which will use the latest params
    });
  }

  NearbyDonorSearchParams? get _searchParams {
    if (_currentPosition == null) return null;
    return NearbyDonorSearchParams(
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
      radiusKm: _distanceKm,
      bloodGroup: _selectedBloodGroup,
      sortBy: _sortBy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: LocalizationService.tr('findDonors', currentLocale),
        actions: [
          // Map / List toggle
          IconButton(
            icon: Icon(_showMap ? Icons.format_list_bulleted_rounded : Icons.map_rounded),
            onPressed: () {
              setState(() => _showMap = !_showMap);
            },
            tooltip: _showMap ? 'Show list' : 'Show map',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Blood Group Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: LocalizationService.tr('all', currentLocale),
                        isSelected: _selectedBloodGroup == null,
                        onTap: () {
                          setState(() => _selectedBloodGroup = null);
                          _onFiltersChanged();
                        },
                      ),
                      ..._bloodGroups.map((bg) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _FilterChip(
                              label: bg,
                              isSelected: _selectedBloodGroup == bg,
                              onTap: () {
                                setState(() => _selectedBloodGroup = bg);
                                _onFiltersChanged();
                              },
                            ),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Distance Slider
                Row(
                  children: [
                    const Icon(Icons.near_me_rounded, size: 18, color: AppColors.grey500),
                    const SizedBox(width: 8),
                    Text('${LocalizationService.tr('within', currentLocale)} ${_distanceKm.round()} ${LocalizationService.tr('km', currentLocale)}', style: AppTypography.bodySmall),
                    Expanded(
                      child: Slider(
                        value: _distanceKm,
                        min: 1,
                        max: 100,
                        divisions: 99,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() => _distanceKm = value);
                          _onFiltersChanged();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Sort Options
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Icon(Icons.sort_rounded, size: 18, color: AppColors.grey500),
                      const SizedBox(width: 8),
                      Text('${LocalizationService.tr('sortBy', currentLocale)}:', style: AppTypography.bodySmall),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: LocalizationService.tr('nearest', currentLocale),
                        isSelected: _sortBy == 'nearest',
                        onTap: () {
                          setState(() => _sortBy = 'nearest');
                          _onFiltersChanged();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: LocalizationService.tr('mostActive', currentLocale),
                        isSelected: _sortBy == 'most_active',
                        onTap: () {
                          setState(() => _sortBy = 'most_active');
                          _onFiltersChanged();
                        },
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: LocalizationService.tr('highDonations', currentLocale),
                        isSelected: _sortBy == 'high_donations',
                        onTap: () {
                          setState(() => _sortBy = 'high_donations');
                          _onFiltersChanged();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results
          Expanded(child: _buildResults(currentLocale)),
        ],
      ),
    );
  }

  Widget _buildResults(String currentLocale) {
    // Loading location
    if (_isLoadingLocation) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Getting your location...'),
          ],
        ),
      );
    }

    // Location error
    if (_hasLocationError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off_rounded, size: 64, color: AppColors.grey300),
              const SizedBox(height: 16),
              Text(
                LocalizationService.tr('locationUnavailable', currentLocale),
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                LocalizationService.tr('locationUnavailableDesc', currentLocale),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(LocalizationService.tr('tryAgain', currentLocale)),
              ),
            ],
          ),
        ),
      );
    }

    // No position yet
    final params = _searchParams;
    if (params == null) {
      return EmptyState(
        icon: Icons.search_rounded,
        title: LocalizationService.tr('searchForDonors', currentLocale),
        subtitle: LocalizationService.tr('searchForDonorsDesc', currentLocale),
      );
    }

    // Search results
    final donorsAsync = ref.watch(findNearbyDonorsProvider(params));

    return donorsAsync.when(
      loading: () => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Searching for donors...'),
          ],
        ),
      ),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                LocalizationService.tr('searchFailed', currentLocale),
                style: AppTypography.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                LocalizationService.tr('couldNotFindDonors', currentLocale),
                style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                onPressed: () => ref.invalidate(findNearbyDonorsProvider(params)),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(LocalizationService.tr('retry', currentLocale)),
              ),
            ],
          ),
        ),
      ),
      data: (donors) {
        if (donors.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/svg/empty_donors.svg',
                    width: 140,
                    height: 140,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    LocalizationService.tr('noDonorsFound', currentLocale),
                    style: AppTypography.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedBloodGroup != null
                        ? LocalizationService.tr('noDonorsBloodGroup', currentLocale)
                            .replaceAll('{bloodGroup}', _selectedBloodGroup!)
                            .replaceAll('{distance}', '${_distanceKm.round()}')
                        : LocalizationService.tr('noDonorsDistance', currentLocale)
                            .replaceAll('{distance}', '${_distanceKm.round()}'),
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    LocalizationService.tr('tryChangingFilters', currentLocale),
                    style: AppTypography.bodySmall.copyWith(color: AppColors.grey400),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Results header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                '${donors.length} donor${donors.length > 1 ? 's' : ''} found',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.grey500),
              ),
            ),
            // Map or list view
            Expanded(
              child: _showMap
                  ? _buildMapView(donors)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: donors.length,
                      itemBuilder: (context, index) {
                        final donor = donors[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: DonorCard(
                            donor: donor,
                            onTap: () {
                              setState(() => _selectedDonor = donor);
                              _showDonorDetailSheet(donor);
                            },
                            onCall: donor.phone != null
                                ? () => _callDonor(donor.phone!)
                                : null,
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Build a full‑screen map view with animated donor markers.
  Widget _buildMapView(List<UserProfile> donors) {
    final center = _currentPosition != null
        ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
        : const LatLng(28.6139, 77.2090);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 12.0,
            onTap: (_, _) => setState(() => _selectedDonor = null),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.blood_donation',
            ),
            // Current location marker
            if (_currentPosition != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: center,
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
                      child: const Icon(Icons.my_location_rounded,
                          color: Colors.white, size: 22),
                    ),
                  ),
                ],
              ),
            // Donor markers
            MarkerLayer(
              markers: donors.map((donor) {
                final isSelected = _selectedDonor?.id == donor.id;
                final distance = GeometryUtils.calculateDistanceInKm(
                  center.latitude,
                  center.longitude,
                  donor.latitude ?? center.latitude,
                  donor.longitude ?? center.longitude,
                );
                return Marker(
                  point: LatLng(
                    donor.latitude ?? center.latitude,
                    donor.longitude ?? center.longitude,
                  ),
                  width: 72,
                  height: 72,
                  child: DonorMapMarker(
                    initials: donor.initials,
                    bloodGroup: donor.bloodGroup,
                    distanceKm: distance,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() => _selectedDonor = donor);
                      _showDonorDetailSheet(donor);
                    },
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        // Floating legend
        Positioned(
          left: 16,
          bottom: 24,
          child: _buildMapLegend(),
        ),
        // Center-on-me button
        Positioned(
          right: 16,
          bottom: 24,
          child: FloatingActionButton.small(
            onPressed: () {
              if (_currentPosition != null) {
                _mapController.move(center, 15.0);
              }
            },
            backgroundColor: Theme.of(context).cardColor,
            child: const Icon(Icons.my_location_rounded),
          ),
        ),
      ],
    );
  }

  Widget _buildMapLegend() {
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
          Text('Legend',
              style: AppTypography.labelMedium
                  .copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: const Text('A',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Text('Donor',
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.grey500)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.my_location_rounded,
                    color: Colors.white, size: 14),
              ),
              const SizedBox(width: 8),
              Text('You',
                  style: AppTypography.labelSmall
                      .copyWith(color: AppColors.grey500)),
            ],
          ),
        ],
      ),
    );
  }

  /// Show an animated bottom sheet with donor details when a marker is tapped.
  void _showDonorDetailSheet(UserProfile donor) {
    final distance = _currentPosition != null
        ? GeometryUtils.calculateDistanceInKm(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            donor.latitude ?? _currentPosition!.latitude,
            donor.longitude ?? _currentPosition!.longitude,
          )
        : 0.0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _DonorDetailSheet(
        donor: donor,
        distanceKm: distance,
        onCall: donor.phone != null ? () => _callDonor(donor.phone!) : null,
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.grey100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.grey700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

/// A beautiful Snapchat‑inspired bottom sheet showing donor details.
class _DonorDetailSheet extends StatelessWidget {
  final UserProfile donor;
  final double distanceKm;
  final VoidCallback? onCall;

  const _DonorDetailSheet({
    required this.donor,
    required this.distanceKm,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bloodColor = donor.bloodGroup != null
        ? AppColors.bloodGroupColor(donor.bloodGroup!)
        : AppColors.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: theme.dividerColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Avatar + Blood group badge + Name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with pulse ring
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: bloodColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: bloodColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  donor.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      donor.name,
                      style: AppTypography.titleLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      donor.email,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.grey500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Blood group badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: bloodColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bloodtype_rounded,
                                  size: 14, color: bloodColor),
                              const SizedBox(width: 4),
                              Text(
                                donor.bloodGroup ?? 'N/A',
                                style: AppTypography.labelMedium.copyWith(
                                  color: bloodColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Distance badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.near_me_rounded,
                                  size: 14, color: AppColors.grey600),
                              const SizedBox(width: 4),
                              Text(
                                '${distanceKm.toStringAsFixed(1)} km',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.grey700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Info cards row
          Row(
            children: [
              _InfoChip(
                icon: Icons.person_rounded,
                label: donor.gender ?? 'N/A',
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.cake_rounded,
                label: donor.age != null ? '${donor.age} yrs' : 'N/A',
              ),
              const SizedBox(width: 12),
              _InfoChip(
                icon: Icons.monitor_weight_rounded,
                label: donor.weight != null ? '${donor.weight!.toInt()} kg' : 'N/A',
              ),
              if (donor.city != null) ...[const SizedBox(width: 12),
                _InfoChip(
                  icon: Icons.location_city_rounded,
                  label: donor.city!,
                ),],
            ],
          ),

          // Last donation info — only shown when there's actual data
          if (donor.lastDonationDate != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: AppColors.success,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Last donation: ${_formatDate(donor.lastDonationDate!)}',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Call button
          if (onCall != null)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: onCall,
                icon: const Icon(Icons.phone_rounded, size: 20),
                label: Text(
                  'Call ${donor.name.split(' ').first}',
                  style: AppTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: AppColors.grey600),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
