import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTypography {
  AppTypography._();

  static TextStyle get displayLarge =>
      GoogleFonts.inter(fontSize: 32.sp, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get displayMedium =>
      GoogleFonts.inter(fontSize: 28.sp, fontWeight: FontWeight.w700, height: 1.2);

  static TextStyle get displaySmall =>
      GoogleFonts.inter(fontSize: 24.sp, fontWeight: FontWeight.w700, height: 1.3);

  static TextStyle get headlineLarge =>
      GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get headlineMedium =>
      GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600, height: 1.3);

  static TextStyle get headlineSmall =>
      GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get titleLarge =>
      GoogleFonts.inter(fontSize: 17.sp, fontWeight: FontWeight.w600, height: 1.4);

  static TextStyle get titleMedium =>
      GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get titleSmall =>
      GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodyMedium =>
      GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get bodySmall =>
      GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w400, height: 1.5);

  static TextStyle get labelLarge =>
      GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelMedium =>
      GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w500, height: 1.4);

  static TextStyle get labelSmall =>
      GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w500, height: 1.4);

  // Special Styles
  static TextStyle get buttonLarge =>
      GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5);

  static TextStyle get buttonMedium =>
      GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, letterSpacing: 0.5);

  static TextStyle get caption =>
      GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w400, color: Colors.grey);

  static TextStyle get overline =>
      GoogleFonts.inter(fontSize: 10.sp, fontWeight: FontWeight.w400, letterSpacing: 1.5);

  static TextStyle get bloodGroup =>
      GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w800, letterSpacing: 1);
}
