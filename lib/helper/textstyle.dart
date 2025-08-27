import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory/common_widget/colors.dart';

class CustomTextStyle {
  static TextStyle customPoppin({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
    );
  }

  static TextStyle customNato({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.notoSansAnatolianHieroglyphs(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      decoration: decoration,
    );
  }

  static TextStyle customRaleway({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.raleway(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      decoration: decoration,
    );
  }

  static TextStyle customUbuntu({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.normal,
    double fontSize = 15,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.ubuntu(
      color: color,
      fontWeight: fontWeight,
      fontSize: fontSize,
      decoration: decoration,
    );
  }
}
