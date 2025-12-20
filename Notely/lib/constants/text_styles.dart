import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors_manager.dart';

/// Centralized text styles following product-guidelines.md
/// Display: Spline Sans for headers
/// Body: Inter for readability
/// All sizes use flutter_screenutil .sp
class TextStyles {
  TextStyles._();

  // === Display / Headers (Spline Sans) ===

  static TextStyle font32PrimaryBold = GoogleFonts.splineSans(
    fontSize: 32.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primary,
  );

  static TextStyle font28WhiteBold = GoogleFonts.splineSans(
    fontSize: 28.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkOnBackground,
  );

  static TextStyle font24WhiteBold = GoogleFonts.splineSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkOnBackground,
  );

  static TextStyle font24BlackBold = GoogleFonts.splineSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.lightOnBackground,
  );

  static TextStyle font20WhiteSemiBold = GoogleFonts.splineSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.darkOnBackground,
  );

  static TextStyle font20BlackSemiBold = GoogleFonts.splineSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: ColorsManager.lightOnBackground,
  );

  // === Body Text (Inter) ===

  static TextStyle font16WhiteRegular = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.darkOnBackground,
  );

  static TextStyle font16BlackRegular = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.lightOnBackground,
  );

  static TextStyle font16GrayRegular = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.darkSecondaryText,
  );

  static TextStyle font14WhiteRegular = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.darkOnBackground,
  );

  static TextStyle font14BlackRegular = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.lightOnBackground,
  );

  static TextStyle font14GrayRegular = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.darkSecondaryText,
  );

  static TextStyle font12GrayRegular = GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.darkSecondaryText,
  );

  // === Button Text ===

  static TextStyle font16PrimaryBold = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primary,
  );

  static TextStyle font16DarkBold = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.darkBackground,
  );

  // === Labels / Chips ===

  static TextStyle font14WhiteMedium = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.darkOnBackground,
  );

  static TextStyle font12WhiteMedium = GoogleFonts.inter(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.darkOnBackground,
  );

  // === Hint / Placeholder ===

  static TextStyle font14HintRegular = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.darkHintText,
  );

  static TextStyle font16HintRegular = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.darkHintText,
  );
}
