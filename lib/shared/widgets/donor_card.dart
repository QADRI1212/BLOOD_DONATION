import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../models/user_profile.dart';

class DonorCard extends StatelessWidget {
  final UserProfile donor;
  final double? distance;
  final VoidCallback? onTap;
  final VoidCallback? onCall;

  const DonorCard({
    super.key,
    required this.donor,
    this.distance,
    this.onTap,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: donor.isAvailable ? AppColors.success.withValues(alpha: 0.3) : AppColors.grey100,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      donor.initials,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (donor.isAvailable)
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
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            donor.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (donor.bloodGroup != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.bloodGroupColor(donor.bloodGroup!)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              donor.bloodGroup!,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.bloodGroupColor(donor.bloodGroup!),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (donor.city != null) ...[
                          Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.grey400),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              donor.city!,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          if (distance != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${distance!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.grey500,
                              ),
                            ),
                          ],
                        ],
                        if (donor.age != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${donor.age} yrs',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              if (onCall != null)
                IconButton(
                  onPressed: onCall,
                  icon: const Icon(Icons.phone_rounded),
                  color: AppColors.secondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
