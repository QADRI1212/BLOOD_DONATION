import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final bool isText;
  final bool isDanger;
  final bool isFullWidth;
  final Color? color;
  final double? height;
  final double? fontSize;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.isText = false,
    this.isDanger = false,
    this.isFullWidth = true,
    this.color,
    this.height,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    if (isText) {
      return TextButton(
        onPressed: isLoading ? null : onPressed,
        child: _buildContent(),
      );
    }

    if (isOutlined) {
      return SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: height ?? 52,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isDanger ? AppColors.error : (color ?? AppColors.primary),
            ),
            foregroundColor: isDanger ? AppColors.error : (color ?? AppColors.primary),
          ),
          child: _buildContent(),
        ),
      );
    }

    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDanger
              ? AppColors.error
              : color ?? AppColors.primary,
          foregroundColor: Colors.white,
        ),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Colors.white,
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTypography.buttonMedium.copyWith(fontSize: fontSize),
          ),
        ],
      );
    }

    return Text(
      label,
      style: AppTypography.buttonMedium.copyWith(fontSize: fontSize),
    );
  }
}
