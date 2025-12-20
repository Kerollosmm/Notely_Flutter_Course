import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors_manager.dart';

class TextStyles {
  static TextStyle font24YellowBold = GoogleFonts.splineSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.primary,
  );

  static TextStyle font24WhiteBold = GoogleFonts.splineSans(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );

  static TextStyle font18WhiteMedium = GoogleFonts.splineSans(
    fontSize: 18.sp,
    fontWeight: FontWeight.w500,
    color: ColorsManager.white,
  );

  static TextStyle font16GrayRegular = GoogleFonts.inter(
    fontSize: 16.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.grey,
  );

  static TextStyle font14WhiteRegular = GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.normal,
    color: ColorsManager.white,
  );

   static TextStyle font20WhiteBold = GoogleFonts.splineSans(
    fontSize: 20.sp,
    fontWeight: FontWeight.bold,
    color: ColorsManager.white,
  );
}
