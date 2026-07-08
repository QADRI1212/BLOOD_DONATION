import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';

/// A circular avatar widget that displays a profile image or initials fallback.
///
/// Features:
/// - Shows a network image when [imageUrl] is provided
/// - Falls back to initials (derived from [name]) when no image
/// - Configurable size, background color, and border
/// - Optional online/offline status indicator
/// - Loading state with shimmer
class ProfileAvatar extends StatelessWidget {
  /// The user's display name (used for initials fallback).
  final String name;

  /// Optional network image URL.
  final String? imageUrl;

  /// Avatar size in logical pixels. Defaults to 48.
  final double size;

  /// Background color for the initials fallback. Defaults to [AppColors.primary].
  final Color? backgroundColor;

  /// Optional border color.
  final Color? borderColor;

  /// Border width in logical pixels. Defaults to 0.
  final double borderWidth;

  /// Whether to show an online status dot in the bottom-right corner.
  final bool showStatus;

  /// Whether the user is online (only applies when [showStatus] is true).
  final bool isOnline;

  /// Optional callback when the avatar is tapped.
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.showStatus = false,
    this.isOnline = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        // The avatar circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor ?? _generateColor(name),
            border: borderWidth > 0 && borderColor != null
                ? Border.all(color: borderColor!, width: borderWidth)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: _buildContent(),
        ),

        // Online/offline status indicator
        if (showStatus)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: size * 0.3,
              height: size * 0.3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.success : AppColors.grey400,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: avatar,
      );
    }

    return avatar;
  }

  /// Build the content inside the avatar circle.
  Widget _buildContent() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (_, _) => _buildInitials(),
        errorWidget: (_, _, _) => _buildInitials(),
      );
    }

    return _buildInitials();
  }

  /// Build the initials text fallback.
  Widget _buildInitials() {
    final initials = _getInitials(name);

    return Center(
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Extract initials from a name string.
  String _getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    if (parts.isNotEmpty && parts.first.isNotEmpty) {
      return parts.first[0].toUpperCase();
    }
    return '?';
  }

  /// Generate a deterministic color from the user's name.
  Color _generateColor(String name) {
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      AppColors.accent,
      AppColors.success,
      AppColors.info,
      const Color(0xFF7C3AED), // Purple
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF59E0B), // Amber
      const Color(0xFF14B8A6), // Teal
    ];

    final hash = name.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return colors[hash % colors.length];
  }
}
