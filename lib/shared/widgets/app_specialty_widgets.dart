import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class BloodGroupBadge extends StatelessWidget {
  final String bloodGroup;
  final double size;
  final bool showLabel;
  final Color? color;

  const BloodGroupBadge({
    super.key,
    required this.bloodGroup,
    this.size = 40,
    this.showLabel = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = color ?? AppColors.bloodGroupColor(bloodGroup);

    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          bloodGroup.toUpperCase(),
          style: AppTypography.bloodGroup.copyWith(
            fontSize: size * 0.4,
            color: bgColor,
          ),
        ),
      ),
    );

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          badge,
          const SizedBox(width: 8),
          Text(
            bloodGroup.toUpperCase(),
            style: AppTypography.titleMedium.copyWith(
              color: bgColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      );
    }

    return badge;
  }
}

class StatusChip extends StatelessWidget {
  final String status;
  final Color? color;

  const StatusChip({
    super.key,
    required this.status,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chipColor = color ?? _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: chipColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
        return AppColors.info;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
      case 'closed':
        return AppColors.grey500;
      case 'critical':
        return AppColors.emergencyCritical;
      case 'urgent':
        return AppColors.emergencyUrgent;
      case 'normal':
        return AppColors.emergencyNormal;
      case 'verified':
        return AppColors.success;
      default:
        return AppColors.grey500;
    }
  }
}

class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String initials;
  final double radius;
  final bool isAvailable;

  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.initials,
    this.radius = 28,
    this.isAvailable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppColors.primaryContainer,
          backgroundImage:
              imageUrl != null ? NetworkImage(imageUrl!) : null,
          child: imageUrl == null
              ? Text(
                  initials,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        ),
        if (isAvailable)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
