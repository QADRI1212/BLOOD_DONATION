import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A Snapchat‑inspired map marker for a donor.
///
/// Shows a coloured circle with the donor's initials and blood group.
/// A pulsing outer ring animates continuously. When [isSelected] is true
/// the marker scales up and the ring becomes brighter.
class DonorMapMarker extends StatefulWidget {
  final String initials;
  final String? bloodGroup;
  final double? distanceKm;
  final bool isSelected;
  final VoidCallback onTap;

  const DonorMapMarker({
    super.key,
    required this.initials,
    this.bloodGroup,
    this.distanceKm,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  State<DonorMapMarker> createState() => _DonorMapMarkerState();
}

class _DonorMapMarkerState extends State<DonorMapMarker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color get _markerColor {
    if (widget.bloodGroup == null) return AppColors.primary;
    return AppColors.bloodGroupColor(widget.bloodGroup!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          final pulseValue = widget.isSelected ? 1.4 : _pulseAnimation.value;
          final size = widget.isSelected ? 80.0 : 72.0;

          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing outer ring
                Transform.scale(
                  scale: pulseValue,
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _markerColor.withValues(alpha: 0.2),
                      border: Border.all(
                        color: _markerColor.withValues(alpha: 0.5),
                        width: 2.5,
                      ),
                    ),
                  ),
                ),
                // Drop shadow beneath the circle
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _markerColor.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
                // Inner solid circle with initials + blood group
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _markerColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5,
                          height: 1.1,
                        ),
                      ),
                      if (widget.bloodGroup != null)
                        Text(
                          widget.bloodGroup!,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                            fontSize: 8,
                            height: 1.0,
                          ),
                        ),
                    ],
                  ),
                ),
                // Distance label below
                if (widget.distanceKm != null && !widget.isSelected)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 0.5),
                      ),
                      child: Text(
                        '${widget.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
