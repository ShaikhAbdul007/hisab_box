import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory/common_widget/colors.dart';

class CustomTextStyle {
  static TextStyle customPoppin({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    double letterSpacing = 0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize.sp,
      letterSpacing: letterSpacing.sp,
    );
  }

  static TextStyle customNato({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    double letterSpacing = 0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.notoSansAnatolianHieroglyphs(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize.sp,
      decoration: decoration,
      letterSpacing: letterSpacing.sp,
    );
  }

  static TextStyle customRaleway({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    double letterSpacing = 0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.raleway(
      color: color,
      fontWeight: fontWeight,

      fontSize: fontSize.sp,
      decoration: decoration,
      letterSpacing: letterSpacing.sp,
    );
  }

  static TextStyle customOpenSans({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    double letterSpacing = 0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.openSans(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize.sp,
      decoration: decoration,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle customMontserrat({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    double letterSpacing = 0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.montserrat(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize.sp,
      decoration: decoration,
      letterSpacing: letterSpacing.sp,
    );
  }
}
