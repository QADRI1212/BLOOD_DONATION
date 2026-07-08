import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFFDC2626); // Blood Red
  static const Color primaryLight = Color(0xFFEF4444);
  static const Color primaryDark = Color(0xFFB91C1C);
  static const Color primaryContainer = Color(0xFFFEE2E2);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Secondary
  static const Color secondary = Color(0xFF3B82F6); // Soft Blue
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF2563EB);
  static const Color secondaryContainer = Color(0xFFDBEAFE);
  static const Color onSecondary = Color(0xFFFFFFFF);

  // Accent
  static const Color accent = Color(0xFF8B5CF6); // Purple accent
  static const Color accentLight = Color(0xFFA78BFA);

  // Status Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFDC2626);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoContainer = Color(0xFFDBEAFE);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Dark Theme
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkOnBackground = Color(0xFFF8FAFC);

  // Blood Group Colors
  static const Color bloodAPositive = Color(0xFFDC2626);
  static const Color bloodANegative = Color(0xFFF87171);
  static const Color bloodBPositive = Color(0xFF2563EB);
  static const Color bloodBNegative = Color(0xFF60A5FA);
  static const Color bloodABPositive = Color(0xFF7C3AED);
  static const Color bloodABNegative = Color(0xFFA78BFA);
  static const Color bloodOPositive = Color(0xFF059669);
  static const Color bloodONegative = Color(0xFF34D399);

  // Emergency Level Colors
  static const Color emergencyCritical = Color(0xFFDC2626);
  static const Color emergencyUrgent = Color(0xFFF59E0B);
  static const Color emergencyNormal = Color(0xFF3B82F6);

  static Color bloodGroupColor(String bloodGroup) {
    switch (bloodGroup.toUpperCase()) {
      case 'A+':
        return bloodAPositive;
      case 'A-':
        return bloodANegative;
      case 'B+':
        return bloodBPositive;
      case 'B-':
        return bloodBNegative;
      case 'AB+':
        return bloodABPositive;
      case 'AB-':
        return bloodABNegative;
      case 'O+':
        return bloodOPositive;
      case 'O-':
        return bloodONegative;
      default:
        return primary;
    }
  }
}
