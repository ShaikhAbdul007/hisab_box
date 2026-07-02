import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory/common_widget/colors.dart';

class CustomTextStyle {
  static double _getFontSize(double size) {
    try {
      if (ScreenUtil().screenWidth > 600) {
        return size;
      }
    } catch (_) {
      return size;
    }
    return size.sp;
  }

  static double _getLetterSpacing(double spacing) {
    try {
      if (ScreenUtil().screenWidth > 600) {
        return spacing;
      }
    } catch (_) {
      return spacing;
    }
    return spacing.sp;
  }

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
      fontSize: _getFontSize(fontSize),
      letterSpacing: _getLetterSpacing(letterSpacing),
      decoration: decoration,
    );
  }

  static TextStyle customNato({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    double letterSpacing = 0,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.arOneSans(
      color: color,
      fontWeight: fontWeight,
      fontSize: _getFontSize(fontSize),
      decoration: decoration,
      letterSpacing: _getLetterSpacing(letterSpacing),
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
      fontSize: _getFontSize(fontSize),
      decoration: decoration,
      letterSpacing: _getLetterSpacing(letterSpacing),
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
      fontSize: _getFontSize(fontSize),
      decoration: decoration,
      letterSpacing: _getLetterSpacing(letterSpacing),
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
      fontSize: _getFontSize(fontSize),
      decoration: decoration,
      letterSpacing: _getLetterSpacing(letterSpacing),
    );
  }
}
